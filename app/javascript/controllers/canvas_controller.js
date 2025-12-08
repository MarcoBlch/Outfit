import { Controller } from "@hotwired/stimulus"
import interact from "interactjs"

export default class extends Controller {
    static targets = ["canvas", "item", "input", "toolbar"]
    static values = { preselected: Array }

    connect() {
        console.log("Canvas controller connected")
        this.canvasTarget.addEventListener("dragover", this.handleDragOver.bind(this))
        this.canvasTarget.addEventListener("drop", this.handleDrop.bind(this))

        this.setupInteract()
    }

    disconnect() {
        console.log("Canvas controller disconnecting")
        // Destroy all interact instances
        if (this.interactables) {
            this.interactables.forEach(interactable => {
                if (interactable && interactable.unset) {
                    interactable.unset()
                }
            })
        }
    }

    setupInteract() {
        // Store reference for cleanup
        this.interactables = []

        // Initialize interact.js
        const canvasItems = interact(".canvas-item")
            .draggable({
                listeners: { move: this.dragMoveListener.bind(this) },
                modifiers: [
                    interact.modifiers.restrictRect({
                        restriction: "parent",
                        endOnly: true
                    })
                ]
            })
            .resizable({
                edges: { left: true, right: true, bottom: true, top: true },
                listeners: { move: this.resizeMoveListener.bind(this) },
                modifiers: [
                    interact.modifiers.restrictEdges({
                        outer: "parent"
                    }),
                    interact.modifiers.aspectRatio({
                        ratio: "preserve"
                    })
                ]
            })
            .gesturable({
                listeners: { move: this.gestureMoveListener.bind(this) }
            })
            .on('tap', (event) => {
                this.selectItem(event.currentTarget)
                event.stopPropagation()
            })

        this.interactables.push(canvasItems)

        // Deselect when clicking canvas background
        this.canvasTarget.addEventListener('click', (e) => {
            if (e.target === this.canvasTarget) {
                this.deselectAll()
            }
        })

        // Load preselected items from AI suggestions
        if (this.hasPreselectedValue && this.preselectedValue.length > 0) {
            this.loadPreselectedItems()
        }
    }

    loadPreselectedItems() {
        const canvasRect = this.canvasTarget.getBoundingClientRect()
        const centerX = canvasRect.width / 2
        const startY = 50

        this.preselectedValue.forEach((item, index) => {
            // Stack items vertically in the center
            const y = startY + (index * 150)
            this.addItemToCanvas(item.id, item.image_src, centerX, y)
        })
    }

    // --- Drag & Drop from Sidebar ---

    dragStart(e) {
        e.dataTransfer.setData("text/plain", e.target.dataset.id)
        e.dataTransfer.setData("image-src", e.target.dataset.imageSrc)
        e.dataTransfer.effectAllowed = "copy"
    }

    handleDragOver(e) {
        e.preventDefault()
        e.dataTransfer.dropEffect = "copy"
    }

    handleDrop(e) {
        e.preventDefault()
        const id = e.dataTransfer.getData("text/plain")
        const src = e.dataTransfer.getData("image-src")

        if (id && src) {
            this.addItemToCanvas(id, src, e.layerX, e.layerY)
        }
    }

    addItemToCanvas(id, src, x, y) {
        const wrapper = document.createElement("div")
        wrapper.className = "canvas-item absolute touch-none select-none group"
        wrapper.dataset.x = x - 64
        wrapper.dataset.y = y - 64
        wrapper.dataset.scale = 1
        wrapper.dataset.angle = 0
        wrapper.dataset.zIndex = 1

        // Initial styles
        wrapper.style.transform = `translate(${x - 64}px, ${y - 64}px) rotate(0deg) scale(1)`
        wrapper.style.width = "128px"
        wrapper.style.height = "128px"
        wrapper.style.zIndex = 1

        // Image
        const img = document.createElement("img")
        img.src = src
        img.className = "w-full h-full object-contain drop-shadow-xl pointer-events-none"
        wrapper.appendChild(img)

        // Selection Border (Hidden by default)
        const border = document.createElement("div")
        border.className = "selection-border absolute inset-0 border-2 border-primary hidden pointer-events-none"
        wrapper.appendChild(border)

        // Hidden Inputs
        this.createHiddenInput(wrapper, "wardrobe_item_id", id)
        this.createHiddenInput(wrapper, "position_x", x - 64)
        this.createHiddenInput(wrapper, "position_y", y - 64)
        this.createHiddenInput(wrapper, "scale", 1)
        this.createHiddenInput(wrapper, "rotation", 0)
        this.createHiddenInput(wrapper, "z_index", 1)

        this.canvasTarget.appendChild(wrapper)
        this.selectItem(wrapper)
    }

    createHiddenInput(wrapper, name, value) {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = `outfit[outfit_items_attributes][][${name}]`
        input.value = value
        input.dataset.field = name
        wrapper.appendChild(input)
    }

    updateHiddenInput(wrapper, field, value) {
        const input = wrapper.querySelector(`input[data-field="${field}"]`)
        if (input) input.value = value
    }

    // --- Interact.js Listeners ---

    dragMoveListener(event) {
        const target = event.target
        const x = (parseFloat(target.dataset.x) || 0) + event.dx
        const y = (parseFloat(target.dataset.y) || 0) + event.dy

        target.style.transform = `translate(${x}px, ${y}px) rotate(${target.dataset.angle || 0}deg) scale(${target.dataset.scale || 1})`

        target.dataset.x = x
        target.dataset.y = y

        this.updateHiddenInput(target, "position_x", x)
        this.updateHiddenInput(target, "position_y", y)
    }

    resizeMoveListener(event) {
        const target = event.target
        let x = (parseFloat(target.dataset.x) || 0)
        let y = (parseFloat(target.dataset.y) || 0)

        target.style.width = event.rect.width + 'px'
        target.style.height = event.rect.height + 'px'

        x += event.deltaRect.left
        y += event.deltaRect.top

        target.style.transform = `translate(${x}px, ${y}px) rotate(${target.dataset.angle || 0}deg) scale(${target.dataset.scale || 1})`

        target.dataset.x = x
        target.dataset.y = y

        this.updateHiddenInput(target, "position_x", x)
        this.updateHiddenInput(target, "position_y", y)
    }

    gestureMoveListener(event) {
        const target = event.target
        const angle = (parseFloat(target.dataset.angle) || 0) + event.da

        target.style.transform = `translate(${target.dataset.x}px, ${target.dataset.y}px) rotate(${angle}deg) scale(${target.dataset.scale || 1})`

        target.dataset.angle = angle
        this.updateHiddenInput(target, "rotation", angle)
    }

    // --- Selection & Toolbar ---

    selectItem(item) {
        this.deselectAll()
        this.selectedItem = item
        item.classList.add("selected")
        item.querySelector(".selection-border").classList.remove("hidden")
        this.showToolbar()
    }

    deselectAll() {
        this.selectedItem = null
        this.canvasTarget.querySelectorAll(".canvas-item").forEach(item => {
            item.classList.remove("selected")
            item.querySelector(".selection-border").classList.add("hidden")
        })
        this.hideToolbar()
    }

    showToolbar() {
        this.toolbarTarget.classList.remove("translate-y-20", "opacity-0")
    }

    hideToolbar() {
        this.toolbarTarget.classList.add("translate-y-20", "opacity-0")
    }

    // --- Toolbar Actions ---

    bringToFront() {
        if (!this.selectedItem) return

        const items = Array.from(this.canvasTarget.querySelectorAll(".canvas-item"))
        const maxZ = Math.max(...items.map(i => {
            const z = parseInt(i.style.zIndex)
            return isNaN(z) ? 1 : z
        }))

        console.log("Bring to Front: Max Z is", maxZ)

        const newZ = maxZ + 1
        this.selectedItem.style.zIndex = newZ
        this.selectedItem.dataset.zIndex = newZ
        this.updateHiddenInput(this.selectedItem, "z_index", newZ)

        console.log("Item Z updated to", newZ)
    }

    sendToBack() {
        if (!this.selectedItem) return

        const items = Array.from(this.canvasTarget.querySelectorAll(".canvas-item"))
        const minZ = Math.min(...items.map(i => {
            const z = parseInt(i.style.zIndex)
            return isNaN(z) ? 1 : z
        }))

        console.log("Send to Back: Min Z is", minZ)

        // Ensure we don't go below 0 if possible, or just decrement
        const newZ = Math.max(0, minZ - 1)

        this.selectedItem.style.zIndex = newZ
        this.selectedItem.dataset.zIndex = newZ
        this.updateHiddenInput(this.selectedItem, "z_index", newZ)

        console.log("Item Z updated to", newZ)
    }

    removeItem() {
        if (!this.selectedItem) return

        this.selectedItem.remove()
        this.deselectAll()
    }
}
