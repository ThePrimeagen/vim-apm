import { display_ui_motion, set_text_class } from "./utils";

// I can make these into something a bit more config driven later...
// oh
const level_config = {
    time_to_stop_animation: 1000 * 3,
    time_before_reset: 1000 * 15,
    time_to_display_motion: 1000 * 3,
    motion_sizes: new Map([
        [3, "text-xl"],
        [4, "text-lg"],
        [5, "text-base"],
        [6, "text-sm"],
        [7, "text-xs"],
    ]),
};

class MotionCounter extends HTMLElement {
    /** @type {Level} */
    level = {
        level: 1,
        apm: 0,
        progress: 0,
        last_update: Date.now(),
        last_set_progress: 0,
        last_motion_executed: { chars: "", count: 0 },
    };

    /** @type {HTMLElement} */
    throbber;

    /** @type {HTMLElement} */
    apm;

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

  html {
      font-size: 250%
  }
</style>

<div class="p-5">
    <div id="motion-container" class="relative pl-3 pr-3 flex w-full h-[3rem] gap-2 bg-slate-900 rounded-md">
        <div id="level" class="w-[20%] text-center text-white text-3xl">1</div>
        <div class="flex-1 text-center text-white throb-target text-3xl">
            <span id="last-motion">w</span>
        </div>
        <div class="flex-1 text-center text-white throb-target text-3xl">
            <span id="apm">0</span>
        </div>

        <div class="absolute bottom-0 left-0 right-0">
            <div class="bg-gray-200 rounded-b-md h-2.5 dark:bg-gray-700">
              <div id="motion-counter-progress-bar" class="bg-blue-600 h-full rounded-b-md" style="width: 45%"></div>
            </div>
        </div>
    </div>
</div>
    `;

        this.throbber = this.querySelector(".throb-target");
        this.progress = this.querySelector("#motion-counter-progress-bar");
        this.level_display = this.querySelector("#level");
        this.last_motion = this.querySelector("#last-motion");
        this.motion_container = this.querySelector("#motion-container");
        this.apm = this.querySelector("#apm");

        this.setupHandlers();
        this.monitor();
    }

    clear_animations() {
        this.motion_container.classList.remove("vibrate");
        this.motion_container.classList.remove("bounce-vibrate");
    }

    update_display() {
        this.progress.style.width = `${Math.floor(this.level.progress * 100)}%`;

        if (this.level.level === 1 && this.level.progress <= 0) {
            this.level_display.innerHTML = ``;
        } else {
            this.level_display.innerHTML = `${this.level.level}`;
        }

        if (
            Date.now() - this.level.last_update <
            level_config.time_to_display_motion
        ) {
            const display = display_ui_motion(
                this.level.last_motion_executed,
            );

            this.last_motion.innerHTML = display
        } else {
            this.last_motion.innerHTML = "";
        }

        const apm_string = this.level.apm > 0 ? `${this.level.apm}` : ""
        this.apm.innerHTML = apm_string

        if (Date.now() - this.level.last_update > level_config.time_to_stop_animation) {
            this.clear_animations();
        }
    }

    reset_level() {

        this.level = {
            level: 1,
            apm: 0,
            progress: 0,
            last_update: Date.now(),
            last_set_progress: 0,
            last_motion_executed: { chars: "", count: 0 },
        };

        this.clear_animations();
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

    /** @param {APMVimModeTimes} mode_times */
    handle_mode_times(mode_times) {}

    /** @param {APMVimApmReport} report */
    handle_stat_report(report) {
        console.log("STAT REPORT", report)
        this.level.apm = report.value.apm
    }

    /** @param {APMVimStateChange} state */
    handle_apm_state_change(state) { }

    /** @param {APMServerMessage} msg */
    handle_message(msg) {
        console.log("message received", msg.type)

        // TODO: how evil?
        // @ts-ignore oh... why have i done this to myself?
        this[`handle_${msg.type}`](msg);
        this.reanimate(this.throbber, "throb");
    }

    /** @param {APMServerMessage[]} messages */
    handle_all_messages(messages) {
        for (const msg of messages) {
            this.handle_message(msg);
        }
    }

    setupHandlers() {
        window.addEventListener("phx:server:messages", (event) => {
            /** @type {APMEvent} */
            const details = event.detail;

            if (details.type === "server-message") {
                const message = details.message
                if (Array.isArray(message)) {
                    this.handle_all_messages(message)
                } else {
                    this.handle_message(message)
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
