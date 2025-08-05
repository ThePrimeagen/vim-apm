class MotionCounter extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.setupHandlers();
    this.innerHTML = `
<style>
  .throb-target {
    transition: transform 0.3s ease;
    display: inline-block;
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
</style>
<div id="motion-counter-throbber" class="bg-slate-900 w-32 h-32 throb-target">💥</div>
    `;
  }

  throb(count) {
    const box = this.querySelector("#motion-counter-throbber");
    box.classList.remove("throb");
    void box.offsetWidth;
    box.classList.add("throb");
    box.innerHTML = "" + count;
  }

  setupHandlers() {
    window.addEventListener("phx:server:messages", (event) => {
      const details = event.detail;
      if (details.type === "motion") {
        this.throb(event.detail.motion_count);
      }
      console.log("phx:server:messages", event);
    });
  }
}

// Define the element (example: <my-throb></my-throb>)
customElements.define("motion-counter", MotionCounter);
