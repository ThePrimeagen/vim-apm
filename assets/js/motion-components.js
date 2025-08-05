import { display_ui_motion, set_text_class } from "./utils";

// I can make these into something a bit more config driven later...
// oh
const level_config = {
    time_before_reset: 1000 * 15,
    time_to_display_motion: 1000 * 3,
    motion_sizes: new Map([
        [1, "text-4xl"],
        [2, "text-3xl"],
        [3, "text-2xl"],
        [4, "text-xl"],
        [5, "text-lg"],
        [6, "text-base"],
        [7, "text-sm"],
        [8, "text-xs"],
    ]),
};

class MotionCounter extends HTMLElement {
    /** @type {Level} */
    level = {
        level: 1,
        progress: 0,
        last_update: Date.now(),
        last_set_progress: 0,
        last_motion_executed: { chars: "", count: 0 },
    };

    /** @type {HTMLElement} */
    throbber;

    /** @type {HTMLElement} */
    progress;

    /** @type {HTMLElement} */
    last_motion;

    /** @type {HTMLElement} */
    motion_container;

    /** @type {HTMLElement} */
    level_display;

    constructor() {
        super();
    }

    connectedCallback() {
        this.innerHTML = `
<style>
  .throb-target {
    transition: transform 0.3s ease;
  }

  .throb {
    animation: bounce-throb 0.4s ease-out;
  }

  @keyframes bounce-throb {
    0%   { transform: scale(1); }
    30%  { transform: scale(1.3); }    /* Big throb */
    50%  { transform: scale(0.9); }    /* Recoil */
    65%  { transform: scale(1.15); }   /* Overshoot bounce */
    80%  { transform: scale(0.98); }   /* Undershoot */
    100% { transform: scale(1); }      /* Settle back */
  }

  /* Small vibrate/shake */
  @keyframes vibrate {
    0%, 100% { transform: translate(0); }
    25% { transform: translate(-1px, 1px); }
    50% { transform: translate(1px, -1px); }
    75% { transform: translate(-1px, -1px); }
  }

  /* Bounce with a bit of rotate */
  @keyframes bounce-vibrate {
    0%, 100% { transform: translate(0); rotate(0deg); }
    25% { transform: translate(-1px, 1px); rotate(1deg); }
    50% { transform: translate(1px, -1px); rotate(0deg); }
    75% { transform: translate(-1px, -1px); rotate(-1deg); }
  }

  .vibrate {
    animation: vibrate 0.2s linear infinite;
  }

  .bounce-vibrate {
    animation: bounce-vibrate 0.4s ease-in-out infinite;
  }
</style>

<div id="motion-container" class="p-3 flex w-[25%] h-[3rem] gap-2 bg-slate-900 rounded-t-lg items-center">
    <div id="level" class="w-[20%] text-center text-white text-4xl">1</div>
    <div id="last-motion" class="w-[30%] text-center text-white throb-target text-4xl">w</div>
    <div class="w-[50%] bg-gray-200 rounded-full h-2.5 dark:bg-gray-700">
      <div id="motion-counter-progress-bar" class="bg-blue-600 h-2.5 rounded-full" style="width: 45%"></div>
    </div>
</div>

    `;

        this.throbber = this.querySelector(".throb-target");
        this.progress = this.querySelector("#motion-counter-progress-bar");
        this.level_display = this.querySelector("#level");
        this.last_motion = this.querySelector("#last-motion");
        this.motion_container = this.querySelector("#motion-container");

        this.setupHandlers();
        this.monitor();
    }

    update_display() {
        this.progress.style.width = `${Math.floor(this.level.progress * 100)}%`;
        this.level_display.innerHTML = `${this.level.level}`;

        if (
            Date.now() - this.level.last_update <
            level_config.time_to_display_motion
        ) {
            const display = display_ui_motion(
                this.level.last_motion_executed,
            );

            this.last_motion.innerHTML = display
            set_text_class(this.last_motion, level_config.motion_sizes, display);
        } else {
            this.last_motion.innerHTML = "";
        }
    }

    reset_level() {
        this.level = {
            level: 1,
            progress: 0,
            last_update: Date.now(),
            last_set_progress: 0,
            last_motion_executed: { chars: "", count: 0 },
        };
        this.motion_container.classList.remove("vibrate");
        this.motion_container.classList.remove("bounce-vibrate");
    }

    /** @param {APMVimMotion} motion */
    handle_motion(motion) {
        const add = 1 / (this.level.level * 10);
        this.level.progress += add;

        if (this.level.progress > 1) {
            this.level.progress = add;
            this.level.level += 1;
        }

        this.level.last_set_progress = this.level.progress;
        this.level.last_update = Date.now();

        if (motion.value.chars === this.level.last_motion_executed.chars) {
            this.level.last_motion_executed.count += 1;
        } else {
            this.level.last_motion_executed = {
                chars: motion.value.chars,
                count: 1,
            };
        }

        if (this.level.level > 3) {
            this.reanimate(this.motion_container, "vibrate");
        }
        if (this.level.level > 5) {
            this.reanimate(this.motion_container, "bounce-vibrate");
        }
    }

    /**
     * @param {HTMLElement} element
     * @param {string} class_name
     * */
    reanimate(element, class_name) {
        element.classList.remove(class_name);
        void element.offsetWidth;
        element.classList.add(class_name);
    }

    /** @param {APMVimWrite} write */
    handle_write(write) {}

    /** @param {APMVimBufEnter} buf_enter */
    handle_buf_enter(buf_enter) {}

    /** @param {APMStatsJson} msg */
    handle_message(msg) {
        // TODO: how evil?
        // @ts-ignore oh... why have i done this to myself?
        this[`handle_${msg.type}`](msg);
        this.reanimate(this.throbber, "throb");
    }

    setupHandlers() {
        window.addEventListener("phx:server:messages", (event) => {
            /** @type {APMEvent} */
            const details = event.detail;

            if (details.type === "server-message") {
                for (const msg of details.message) {
                    this.handle_message(msg);
                }
            }
        });
    }

    monitor() {
        const now = Date.now();
        const delta = now - this.level.last_update;
        const percent = Math.min(1, delta / level_config.time_before_reset);
        const next_progress = this.level.last_set_progress * (1 - percent);

        this.level.progress = next_progress;

        if (this.level.progress < 0.001) {
            this.reset_level();
        }

        this.update_display();
        requestAnimationFrame(this.monitor.bind(this));
    }
}

// Define the element (example: <my-throb></my-throb>)
customElements.define("motion-counter", MotionCounter);
