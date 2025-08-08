import bus from "../bus";
let id = 0;

type ProgressArgs = {
    interval: number;
    time_to_stop: number;
    progress: number;
    start: number;
};

class Progress extends HTMLElement {
    progress: HTMLElement;
    enabled: boolean;
    progress_args: {
        interval: number;
        max_duration: number;
        starting_progress: number;
        start: number;
    }

    constructor() {
        super();
        this.enabled = false;
    }

    static get observedAttributes() {
        return ["data-progress"];
    }

    attributeChangedCallback(name, oldValue, newValue) {
        if (!this.progress_args) {
            console.log("no progress args");
            return;
        }

        console.log("attributeChangedCallback", name, oldValue, newValue);
        this.progress_args.start = Date.now();
        this.progress_args.starting_progress = parseFloat(newValue);
    }

    connectedCallback() {
        const _id = id++;
        this.enabled = true;
        this.innerHTML = `<div class="bg-gray-200 rounded-b-md h-2.5 dark:bg-gray-700">
  <div id="progress-bar-${_id}" class="bg-blue-600 h-full rounded-b-md" style="width: 45%"></div>
</div>`;
        this.progress = this.querySelector(`#progress-bar-${_id}`);
        this.progress_args = {
            interval: +this.dataset.interval,
            max_duration: +this.dataset.max_duration,
            starting_progress: +this.dataset.max_duration,
            start: Date.now(),
        };
        this.setup_countdown();
    }

    disconnectedCallback() {
        this.enabled = false;
    }

    setup_countdown() {
        if (!this.enabled) {
            return;
        }

        const args = this.progress_args;
        const diff = Date.now() - args.start;
        const progress = args.starting_progress * (1 - diff / args.max_duration);

        console.log("setup_countdown", progress, diff, args);
        if (progress <= 0) {
            this.progress.style.width = "0%";
            bus.emit("progress_complete", {});
        } else {
            this.progress.style.width = `${Math.floor(progress * 100)}%`;
            setTimeout(() => this.setup_countdown(), args.interval);
        }
    }
}

customElements.define("progress-bar", Progress);

export default Progress;
