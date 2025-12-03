import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["canvas", "item", "input"]

    connect() {
        this.canvasTarget.addEventListener("dragover", this.handleDragOver.bind(this))
        this.canvasTarget.addEventListener("drop", this.handleDrop.bind(this))
    }

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
        wrapper.className = "absolute w-32 h-32 cursor-move group"
        wrapper.style.left = `${x - 64}px`
        wrapper.style.top = `${y - 64}px`

        // Image
        const img = document.createElement("img")
        img.src = src
        img.className = "w-full h-full object-contain drop-shadow-xl"
        wrapper.appendChild(img)

        // Hidden Input for Form Submission
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "outfit[outfit_items_attributes][][wardrobe_item_id]"
        input.value = id
        wrapper.appendChild(input)

        // Position Inputs (Optional for MVP, but good structure)
        const posX = document.createElement("input")
        posX.type = "hidden"
        posX.name = "outfit[outfit_items_attributes][][position_x]"
        posX.value = x
        wrapper.appendChild(posX)

        const posY = document.createElement("input")
        posY.type = "hidden"
        posY.name = "outfit[outfit_items_attributes][][position_y]"
        posY.value = y
        wrapper.appendChild(posY)

        // Remove Button
        const removeBtn = document.createElement("button")
        removeBtn.className = "absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
        removeBtn.innerHTML = '<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>'
        removeBtn.onclick = (e) => {
            e.preventDefault()
            wrapper.remove()
        }
        wrapper.appendChild(removeBtn)

        this.canvasTarget.appendChild(wrapper)
    }
}
