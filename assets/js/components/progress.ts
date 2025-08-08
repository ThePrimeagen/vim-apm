import bus from "../bus";
let id = 0;

type ProgressArgs = {
    interval: number;
    time_to_stop: number;
    progress: number;
    start: number;
}

class Progress extends HTMLElement {
    progress: HTMLElement;
    enabled: boolean;

    constructor() {
        super();
        this.enabled = false;
    }


    static get observedAttributes() {
        return ["interval", "time-to-stop", "progress"];
    }

    connectedCallback() {
        const _id = id++;
        this.enabled = true
        this.innerHTML = `
<div class="bg-gray-200 rounded-b-md h-2.5 dark:bg-gray-700">
  <div id="progress-bar-${_id}" class="bg-blue-600 h-full rounded-b-md" style="width: 45%"></div>
</div>
`
        this.progress = this.querySelector(`#progress-bar-${_id}`);

        const args = {
            interval: +this.getAttribute("interval"),
            time_to_stop: +this.getAttribute("time-to-stop"),
            progress: +this.getAttribute("progress"),
            start: Date.now(),
        }

        console.log("starting countdown", args);
        this.setup_countdown(args);
    }

    disconnectedCallback() {
        console.log("disconnected");
        this.enabled = false
    }

    setup_countdown(args: ProgressArgs) {
        if (!this.enabled) {
            return;
        }

        const diff = Date.now() - args.start;
        if (diff > args.time_to_stop && args.progress == 0) {
            this.progress.style.width = "0%";
            bus.emit("progress_complete", {});
        } else {
            const progress = args.progress * (1 - diff / args.time_to_stop);
            this.progress.style.width = `${Math.floor(progress * 100)}%`;
            setTimeout(() => this.setup_countdown(args), args.interval);
        }
    }
}

customElements.define("progress-bar", Progress);

export default Progress;

