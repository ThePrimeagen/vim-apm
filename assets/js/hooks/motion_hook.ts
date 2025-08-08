export default {
  mounted() {
    this.reanimate()
  },

  updated() {
    this.reanimate()
  },

  reanimate() {
    const className = "throb"
    this.el.classList.remove(className)
    void this.el.offsetWidth
    this.el.classList.add(className)
  }
}

