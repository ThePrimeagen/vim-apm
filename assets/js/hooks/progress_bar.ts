export default {
    mounted() {
        this.sync();
    },

    updated() {
        this.sync();
    },

    sync() {
        const p = parseFloat(this.el.dataset.progress || "0");
        console.log("sync", p);
        // prefer a property on the element so you don’t re-trigger LV diffs
        this.el.setAttribute("progress", String(p)); // or this.el.progress = p if your element supports it
    },
};
