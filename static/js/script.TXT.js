// =========================================================================
// BOGOTENIS - Versión Estática (sin Flask/MySQL)
// Productos hardcodeados con imágenes reales de la carpeta static/img/
// =========================================================================

const IMG_BASE = "../static/img/";

const products = [
    {
        id: 1, marca: "Nike", nombre: "Air Max 270 React",
        precio: 389900, stock: 15, categoria_id: 1, en_oferta: 1, estado: "disponible",
        variantes: [
            { color_nombre: "Negro", color_code: "#1a1a1a", imagen: "shoe1-1.png" },
            { color_nombre: "Blanco", color_code: "#f5f5f5", imagen: "shoe1-1.png" }
        ],
        tallas: ["38", "39", "40", "41", "42", "43", "44"]
    },
    {
        id: 2, marca: "Adidas", nombre: "Ultraboost 22",
        precio: 459900, stock: 12, categoria_id: 3, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Azul", color_code: "#f5f5f5", imagen: "shoe2-1.png" }
        ],
        tallas: ["38", "39", "40", "41", "42", "43"]
    },
    {
        id: 3, marca: "New Balance", nombre: "574 Classic",
        precio: 349900, stock: 10, categoria_id: 2, en_oferta: 1, estado: "disponible",
        variantes: [
            { color_nombre: "Gris", color_code: "#7f8c8d", imagen: "shoe3-1.png" },
            { color_nombre: "Verde", color_code: "#27ae60", imagen: "shoe3-1.png" }
        ],
        tallas: ["38", "39", "40", "41", "42", "43", "44"]
    },
    {
        id: 4, marca: "Puma", nombre: "RS-X Reinvention",
        precio: 299900, stock: 8, categoria_id: 1, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Multicolor", color_code: "#e74c3c", imagen: "shoe4-1.png" }
        ],
        tallas: ["39", "40", "41", "42", "43"]
    },
    {
        id: 5, marca: "Reebok", nombre: "Classic Leather",
        precio: 279900, stock: 14, categoria_id: 2, en_oferta: 1, estado: "disponible",
        variantes: [
            { color_nombre: "Negro", color_code: "#1a1a1a", imagen: "shoe5-1.png" },
            { color_nombre: "Blanco", color_code: "#f5f5f5", imagen: "shoe5-2.png" }
        ],
        tallas: ["38", "39", "40", "41", "42", "43", "44"]
    },
    {
        id: 6, marca: "Converse", nombre: "Chuck Taylor All Star",
        precio: 199900, stock: 20, categoria_id: 2, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Negro", color_code: "#1a1a1a", imagen: "shoe6-1.png" }
        ],
        tallas: ["36", "37", "38", "39", "40", "41", "42"]
    },
    {
        id: 7, marca: "Vans", nombre: "Old Skool",
        precio: 249900, stock: 18, categoria_id: 2, en_oferta: 1, estado: "disponible",
        variantes: [
            { color_nombre: "Negro/Rojo", color_code: "#2c3e50", imagen: "shoe7-1.png" }
        ],
        tallas: ["37", "38", "39", "40", "41", "42", "43"]
    },
    {
        id: 8, marca: "Air Jordan", nombre: "Retro 4 Toro",
        precio: 599900, stock: 6, categoria_id: 1, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Negro", color_code: "#c0392b", imagen: "shoe8-1.png" },
           
        ],
        tallas: ["39", "40", "41", "42", "43", "44"]
    },
    {
        id: 9, marca: "Nike", nombre: "Downshifter 12",
        precio: 259900, stock: 22, categoria_id: 3, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Azul", color_code: "#2c3e50", imagen: "shoe10-1.png" },
            { color_nombre: "Gris", color_code: "#95a5a6", imagen: "shoe10-2.png" }
        ],
        tallas: ["38", "39", "40", "41", "42", "43", "44"]
    },
    {
        id: 10, marca: "Adidas", nombre: "Court Lite 2",
        precio: 229900, stock: 16, categoria_id: 4, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Blanco", color_code: "Adidas1", imagen: "shoe11-1.png" }
        ],
        tallas: ["38", "39", "40", "41", "42", "43"]
    },
    {
        id: 11, marca: "Under Armour", nombre: "Charged Assert 9",
        precio: 319900, stock: 9, categoria_id: 3, en_oferta: 1, estado: "disponible",
        variantes: [
            { color_nombre: "Negro", color_code: "#1a1a1a", imagen: "shoe13-1.png" }
        ],
        tallas: ["39", "40", "41", "42", "43", "44"]
    },
    {
        id: 12, marca: "Fila", nombre: "Disruptor II",
        precio: 269900, stock: 11, categoria_id: 2, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Blanco", color_code: "#f5f5f5", imagen: "shoe14-1.png" }
        ],
        tallas: ["37", "38", "39", "40", "41", "42"]
    },
    {
        id: 13, marca: "Salomon", nombre: "Speedcross 6",
        precio: 489900, stock: 7, categoria_id: 3, en_oferta: 0, estado: "disponible",
        variantes: [
            { color_nombre: "Negro/Verde", color_code: "#024b20", imagen: "shoe15-1.png" }
        ],
        tallas: ["39", "40", "41", "42", "43", "44"]
    }
];

const categorias = [
    { id: 1, nombre: "Deportivos" },
    { id: 2, nombre: "Casual" },
    { id: 3, nombre: "Running" },
    { id: 4, nombre: "Formal" }
];

// =========================================================================
const offerProducts = products;

let cart = [];
let currentSelectedColor = '';
let currentSelectedSize = '';
let activeProduct = null;
let activePriceMode = 'regular';

const formatter = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0
});

function imagenUrl(nombreArchivo) {
    return IMG_BASE + nombreArchivo;
}

// ---------------------------------------------------------------
// FILTRO DE CATEGORÍAS
// ---------------------------------------------------------------
function filterShoes(categoryId, button = null) {
    const grid = document.getElementById('main-grid');
    if (!grid) return;
    grid.innerHTML = '';

    document.querySelectorAll('.brand-filter-btn').forEach(btn => btn.classList.remove('active'));
    if (button) button.classList.add('active');

    const filtered = categoryId === 'all'
        ? products
        : products.filter(p => p.categoria_id === Number(categoryId));

    if (filtered.length === 0) {
        grid.innerHTML = '<p class="text-center text-muted">No hay productos en esta categoría.</p>';
        return;
    }

    filtered.forEach(product => {
        const defaultImage = imagenUrl(product.variantes[0].imagen);
        const card = document.createElement('div');
        card.className = 'product-card';
        card.setAttribute('onclick', `openProductModal(${product.id}, 'regular')`);

        card.innerHTML = `
            <div class="product-image">
                <img src="${defaultImage}" alt="${product.nombre}" style="width: 100%; height: 100%; object-fit: contain;">
            </div>
            <div class="product-brand">${product.marca}</div>
            <h3 class="product-name">${product.nombre}</h3>
            <div class="product-price-row">
                <span class="price-tag">${formatter.format(product.precio)}</span>
                <button class="btn-add" onclick="quickAddToCart(${product.id}, 'regular', event)">+</button>
            </div>
        `;
        grid.appendChild(card);
    });
}

document.querySelectorAll('.brand-filter-btn').forEach(btn => {
    btn.addEventListener('click', () => filterShoes(btn.dataset.cat, btn));
});

// ---------------------------------------------------------------
// GRILLA DE OFERTAS (-20%)
// ---------------------------------------------------------------
function renderOffersGrid() {
    const grid = document.getElementById('offers-grid');
    if (!grid) return;
    grid.innerHTML = '';

    const saleProducts = offerProducts.filter(p => p.en_oferta == 1);

    saleProducts.forEach(product => {
        const defaultImage = imagenUrl(product.variantes[0].imagen);
        const discountedPrice = product.precio * 0.80;

        const card = document.createElement('div');
        card.className = 'product-card offer-card';
        card.setAttribute('onclick', `openProductModal(${product.id}, 'sale')`);

        card.innerHTML = `
            <div class="product-image relative-box">
                <span class="discount-pill">20% OFF</span>
                <img src="${defaultImage}" alt="${product.nombre}" style="width: 100%; height: 100%; object-fit: contain;">
            </div>
            <div class="product-brand">${product.marca}</div>
            <h3 class="product-name">${product.nombre}</h3>
            <div class="product-price-row">
                <div>
                    <span class="old-price-label">${formatter.format(product.precio)}</span>
                    <span class="price-tag sale-price d-block">${formatter.format(discountedPrice)}</span>
                </div>
                <button class="btn-add btn-sale-add" onclick="quickAddToCart(${product.id}, 'sale', event)">+</button>
            </div>
        `;
        grid.appendChild(card);
    });
}

// ---------------------------------------------------------------
// CARRITO
// ---------------------------------------------------------------
function buscarProducto(productId) {
    return products.find(p => p.id === productId);
}

function quickAddToCart(productId, mode, event) {
    event.stopPropagation();
    const product = buscarProducto(productId);
    if (!product) return;

    const finalPrice = mode === 'sale' ? product.precio * 0.80 : product.precio;

    cart.push({
        product_id: product.id,
        brand: product.marca,
        name: product.nombre + (mode === 'sale' ? ' (% Oferta)' : ''),
        price: finalPrice,
        selectedColor: product.variantes[0].color_code,
        color_name: product.variantes[0].color_nombre,
        selectedSize: product.tallas[0],
        size: product.tallas[0]
    });
    updateCartUI();
    document.getElementById('btn-cart-toggle').click();
}

function openProductModal(productId, mode = 'regular') {
    const product = buscarProducto(productId);
    if (!product) return;

    activeProduct = product;
    activePriceMode = mode;

    document.getElementById('modal-brand').innerText = product.marca;
    document.getElementById('modal-name').innerText = product.nombre + (mode === 'sale' ? ' (% Oferta)' : '');

    const finalPrice = mode === 'sale' ? product.precio * 0.80 : product.precio;
    document.getElementById('modal-price').innerText = formatter.format(finalPrice);

    currentSelectedSize = product.tallas[0];
    currentSelectedColor = product.variantes[0].color_code;

    const colorContainer = document.getElementById('modal-colors');
    colorContainer.innerHTML = '';

    product.variantes.forEach((variante, idx) => {
        colorContainer.innerHTML += `
            <div class="color-option ${idx === 0 ? 'selected' : ''}"
                 style="background-color: ${variante.color_code}"
                 title="${variante.color_nombre}"
                 onclick="changeProductColor(this, '${imagenUrl(variante.imagen)}', '${variante.color_code}', '${variante.color_nombre}')">
            </div>`;
    });

    const viewer = document.getElementById('shoe-image-viewer');
    viewer.innerHTML = `<img src="${imagenUrl(product.variantes[0].imagen)}" alt="Zapato" id="modal-main-shoe-image" style="width: 100%; height: 100%; object-fit: contain;">`;

    const sizeContainer = document.getElementById('modal-sizes');
    sizeContainer.innerHTML = '';
    product.tallas.forEach((talla, idx) => {
        sizeContainer.innerHTML += `
            <button class="size-option ${idx === 0 ? 'selected' : ''}" onclick="selectSizeOption(this, '${talla}')">
                CO ${talla}
            </button>`;
    });

    let currentColorName = product.variantes[0].color_nombre;

    document.getElementById('modal-add-to-cart-btn').onclick = () => {
        const itemPrice = activePriceMode === 'sale' ? activeProduct.precio * 0.80 : activeProduct.precio;
        cart.push({
            product_id: activeProduct.id,
            brand: activeProduct.marca,
            name: activeProduct.nombre + (activePriceMode === 'sale' ? ' (% Oferta)' : ''),
            price: itemPrice,
            selectedColor: currentSelectedColor,
            color_name: currentColorName,
            selectedSize: currentSelectedSize,
            size: currentSelectedSize
        });
        updateCartUI();
        closeProductModal();
        document.getElementById('btn-cart-toggle').click();
    };

    document.getElementById('product-modal').classList.add('active');
}

function changeProductColor(element, imagePath, colorCode, colorName) {
    document.querySelectorAll('.color-option').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    currentSelectedColor = colorCode;
    const imgEl = document.getElementById('modal-main-shoe-image');
    if (imgEl) imgEl.src = imagePath;
}

function selectSizeOption(element, size) {
    document.querySelectorAll('.size-option').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    currentSelectedSize = size;
}

function closeProductModal() {
    document.getElementById('product-modal').classList.remove('active');
}

function updateCartUI() {
    const container = document.getElementById('cart-items-container');
    const totalCount = document.getElementById('cart-count');
    const totalPrice = document.getElementById('cart-total-price');
    if (!container) return;

    let total = 0;
    container.innerHTML = '';

    cart.forEach((item, index) => {
        total += item.price;
        container.innerHTML += `
            <div class="cart-item">
                <div class="cart-item-details">
                    <div class="cart-item-title">${item.brand} - ${item.name}</div>
                    <div class="cart-item-meta">
                        Talla: CO ${item.selectedSize} | Color: <span class="cart-color-dot" style="background:${item.selectedColor};"></span>
                    </div>
                    <div class="cart-item-price">${formatter.format(item.price)}</div>
                </div>
                <button class="cart-item-remove" title="Eliminar artículo" onclick="removeFromCart(${index})">
                    <i class="fas fa-trash-alt"></i>
                </button>
            </div>
        `;
    });

    totalCount.innerText = cart.length;
    totalPrice.innerText = formatter.format(total);
}

function removeFromCart(index) {
    cart.splice(index, 1);
    updateCartUI();
}

document.getElementById('btn-cart-toggle')?.addEventListener('click', () => { document.getElementById('cart-sidebar').classList.add('active'); });
document.getElementById('close-cart-sidebar')?.addEventListener('click', () => { document.getElementById('cart-sidebar').classList.remove('active'); });
document.getElementById('clear-cart')?.addEventListener('click', () => { cart = []; updateCartUI(); });

// ---------------------------------------------------------------
// FINALIZAR PEDIDO: abre WhatsApp directamente 
// ---------------------------------------------------------------
function finalizarPedido() {
    if (cart.length === 0) { alert("El carrito está vacío"); return; }

    let totalValue = 0;
    cart.forEach(item => totalValue += item.price);
    const itemsText = cart.map(item => `- ${item.brand} ${item.name} (Talla CO: ${item.selectedSize})`).join('%0A');
    const message = `*NUEVO PEDIDO BOGOTENIS*%0A%0A${itemsText}%0A%0A*TOTAL:* ${formatter.format(totalValue)}`;

    window.open(`https://wa.me/573004486406?text=${message}`, '_blank');

    cart = [];
    updateCartUI();
}

// ---------------------------------------------------------------
// SOPORTE
// ---------------------------------------------------------------
function openSupportModal(event) {
    if (event) event.preventDefault();
    const supportModal = document.getElementById('support-modal');
    if (supportModal) supportModal.classList.add('active');
}

function closeSupportModal() {
    const supportModal = document.getElementById('support-modal');
    if (supportModal) supportModal.classList.remove('active');
}

window.addEventListener('click', (e) => {
    const supportModal = document.getElementById('support-modal');
    if (e.target === supportModal) closeSupportModal();
});

// ---------------------------------------------------------------
// INICIALIZACIÓN
// ---------------------------------------------------------------
window.onload = () => {
    if (document.getElementById('main-grid')) filterShoes('all');
    if (document.getElementById('offers-grid')) renderOffersGrid();
};
