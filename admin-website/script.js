
/* ==================================================
   KONEKSI SUPABASE ED MANAGEMENT
================================================== */

const SUPABASE_URL =
  "https://cqzzrxeukcxkstdxfeiy.supabase.co";

const SUPABASE_PUBLISHABLE_KEY =
  "sb_publishable_forJiulthVcRmNGHfQUO1g_1DkiL3pq";

const supabaseClient = window.supabase.createClient(
  SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY
);

console.log("Client Supabase berhasil dibuat");

/* ==================================================
   ELEMENT HTML
================================================== */

const pageContent = document.getElementById("pageContent");
const pageTitle = document.getElementById("pageTitle");
const pageDescription = document.getElementById("pageDescription");
const breadcrumbTitle = document.getElementById("breadcrumbTitle");
const approvalBadge = document.getElementById("approvalBadge");
const toast = document.getElementById("toast");

const loginPage = document.getElementById("loginPage");
const adminApp = document.getElementById("adminApp");
const loginForm = document.getElementById("loginForm");
const loginMessage = document.getElementById("loginMessage");
const loginButton = document.getElementById("loginBtn");

let currentPage = "dashboard";
let profiles = [];
let sellers = [];
let buyers = [];

/* ==================================================
   INFORMASI HALAMAN
================================================== */

const pageInfo = {
  dashboard: [
    "Dashboard",
    "Pantau aktivitas marketplace ED Management."
  ],
  approvals: [
    "Persetujuan Penjual",
    "Periksa pendaftaran sebelum penjual dapat berjualan."
  ],
  buyers: [
    "Data Pembeli",
    "Daftar akun pembeli yang terdaftar."
  ],
  sellers: [
    "Data Penjual",
    "Daftar penjual beserta status pendaftarannya."
  ],
  products: [
    "Data Produk",
    "Pantau produk yang tersedia di marketplace."
  ],
  orders: [
    "Data Pesanan",
    "Pantau pesanan dari pembeli."
  ],
  reports: [
    "Laporan Penjualan",
    "Ringkasan transaksi berdasarkan data yang tersedia."
  ]
};

/* ==================================================
   DATA CONTOH
   PRODUK DAN PESANAN BELUM TERHUBUNG KE DATABASE
================================================== */

const products = [
  {
    name: "Tas Rajut",
    seller: "Ayu Craft",
    price: 17000,
    status: "Aktif"
  },
  {
    name: "Keripik Pisang",
    seller: "Keripik Rahma",
    price: 10000,
    status: "Aktif"
  },
  {
    name: "Kopi Cendana",
    seller: "Kopi Budi",
    price: 25000,
    status: "Aktif"
  }
];

const orders = [
  {
    id: "ORD-001",
    buyer: "Rina Amelia",
    product: "Tas Rajut",
    total: 17000,
    status: "Diproses"
  },
  {
    id: "ORD-002",
    buyer: "Doni Pratama",
    product: "Kopi Cendana",
    total: 50000,
    status: "Selesai"
  },
  {
    id: "ORD-003",
    buyer: "Nadia Putri",
    product: "Keripik Pisang",
    total: 20000,
    status: "Menunggu"
  }
];

/* ==================================================
   UTILITAS
================================================== */

function escapeHTML(value) {
  return String(value ?? "").replace(/[&<>"']/g, char => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;"
  })[char]);
}

function rupiah(value) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0
  }).format(value || 0);
}

function initials(name) {
  const value = String(name || "Pengguna").trim();

  return value
    .split(/\s+/)
    .slice(0, 2)
    .map(part => part[0] || "")
    .join("")
    .toUpperCase();
}

function formatDate(value) {
  if (!value) return "-";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return "-";

  return new Intl.DateTimeFormat("id-ID", {
    day: "numeric",
    month: "short",
    year: "numeric"
  }).format(date);
}

function showToast(message) {
  if (!toast) {
    console.log(message);
    return;
  }

  toast.textContent = message;
  toast.classList.add("show");

  clearTimeout(showToast.timer);

  showToast.timer = setTimeout(() => {
    toast.classList.remove("show");
  }, 3000);
}

function statusBadge(status) {
  const normalized = String(status || "").toLowerCase();

  let label = status || "Tidak diketahui";
  let className = "status-pending";

  if (["approved", "disetujui", "aktif", "selesai"].includes(normalized)) {
    className = "status-approved";
  } else if (
    ["rejected", "ditolak", "nonaktif", "dibatalkan"].includes(normalized)
  ) {
    className = "status-rejected";
  }

  return `
    <span class="status ${className}">
      ${escapeHTML(label)}
    </span>`;
}

function personCell(name, email) {
  return `
    <div class="person-cell">
      <div class="person-avatar">
        ${escapeHTML(initials(name))}
      </div>
      <div class="person-details">
        <strong>${escapeHTML(name || "Tanpa nama")}</strong>
        <span>${escapeHTML(email || "-")}</span>
      </div>
    </div>`;
}

/* ==================================================
   STATUS PENJUAL
================================================== */

function getSellerStatus(profile) {
  const status = String(profile.seller_status || "").toLowerCase();

  if (status === "approved") return "Disetujui";
  if (status === "rejected") return "Ditolak";

  // Penjual yang belum memiliki status dianggap menunggu.
  return "Menunggu";
}

function mapSeller(profile) {
  return {
    id: profile.id,
    name: profile.nama || "Tanpa nama",
    email: profile.email || "",
    business: "-",
    date: formatDate(profile.created_at),
    status: getSellerStatus(profile)
  };
}

function getPendingCount() {
  return sellers.filter(seller => seller.status === "Menunggu").length;
}

function updateApprovalBadge() {
  if (!approvalBadge) return;

  const count = getPendingCount();

  approvalBadge.textContent = count;
  approvalBadge.style.display = count ? "inline-block" : "none";
}

/* ==================================================
   AUTENTIKASI ADMIN
================================================== */

function showLogin(message = "") {
  if (loginPage) loginPage.hidden = false;
  if (adminApp) adminApp.hidden = true;

  if (loginMessage) {
    loginMessage.textContent = message;
  }
}

function showAdmin() {
  if (loginPage) loginPage.hidden = true;
  if (adminApp) adminApp.hidden = false;

  if (loginMessage) {
    loginMessage.textContent = "";
  }
}

async function verifyAdmin() {
  const { data: sessionData, error: sessionError } =
    await supabaseClient.auth.getSession();

  if (sessionError) {
    console.error("Gagal memeriksa sesi:", sessionError.message);
    showLogin("Gagal memeriksa sesi login. Silakan coba lagi.");
    return false;
  }

  const user = sessionData.session?.user;

  if (!user) {
    showLogin();
    return false;
  }

  // Periksa role pengguna yang sedang login.
  const { data: profile, error: profileError } =
    await supabaseClient
      .from("profiles")
      .select("id, nama, email, role")
      .eq("id", user.id)
      .maybeSingle();

  if (profileError) {
    console.error("Gagal memeriksa role admin:", profileError);

    showLogin(
      "Profil tidak dapat dibaca. Periksa kebijakan RLS tabel profiles."
    );

    return false;
  }

  if (!profile || profile.role !== "admin") {
    await supabaseClient.auth.signOut();

    showLogin("Akun ini tidak memiliki akses admin.");
    return false;
  }

  showAdmin();

  const adminName = document.getElementById("adminName");
  const adminEmailLabel = document.getElementById("adminEmailLabel");

  if (adminName) {
    adminName.textContent = profile.nama || "Administrator";
  }

  if (adminEmailLabel) {
    adminEmailLabel.textContent = profile.email || user.email || "";
  }

  // Baru baca semua profil setelah role admin terverifikasi.
  const loaded = await loadProfiles();

  if (!loaded) {
    showToast("Profil gagal dimuat. Periksa Console.");
    return false;
  }

  return true;
}

if (loginForm) {
  loginForm.addEventListener("submit", async event => {
    event.preventDefault();

    const email = document
      .getElementById("adminEmail")
      .value.trim();

    const password = document
      .getElementById("adminPassword")
      .value;

    if (loginButton) loginButton.disabled = true;

    if (loginMessage) loginMessage.textContent = "";

    try {
      const { error } = await supabaseClient.auth.signInWithPassword({
        email,
        password
      });

      if (error) throw error;

      const allowed = await verifyAdmin();

      if (allowed) {
        renderPage("dashboard");
        showToast("Login admin berhasil.");
      }
    } catch (error) {
      console.error("Login gagal:", error);

      showLogin(
        error.message || "Login gagal. Periksa email dan password."
      );
    } finally {
      if (loginButton) loginButton.disabled = false;
    }
  });
}

/* ==================================================
   MEMBACA PROFILES DARI SUPABASE
================================================== */

async function loadProfiles() {
  const { data, error } = await supabaseClient
    .from("profiles")
    .select("id, nama, email, role, seller_status, created_at")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Gagal membaca tabel profiles:", error);
    showToast("Gagal membaca data profil dari Supabase.");
    return false;
  }

  profiles = data || [];

  buyers = profiles
    .filter(profile => profile.role === "buyer")
    .map(profile => ({
      id: profile.id,
      name: profile.nama || "Tanpa nama",
      email: profile.email || "",
      date: formatDate(profile.created_at)
    }));

  sellers = profiles
    .filter(profile => profile.role === "seller")
    .map(mapSeller);

  console.log("Berhasil membaca tabel profiles!");
  console.log("Jumlah seluruh profil:", profiles.length);
  console.log("Jumlah pembeli:", buyers.length);
  console.log("Jumlah penjual:", sellers.length);
  console.log("Penjual menunggu:", getPendingCount());

  updateApprovalBadge();

  return true;
}

/* ==================================================
   KARTU STATISTIK
================================================== */

function statCard(title, number, icon, note) {
  return `
    <article class="stat-card">
      <div class="stat-top">
        <span class="stat-title">${title}</span>
        <span class="stat-icon">${icon}</span>
      </div>
      <div class="stat-number">${number}</div>
      <div class="stat-note">${note}</div>
    </article>`;
}

/* ==================================================
   DASHBOARD
================================================== */

function renderDashboard() {
  pageContent.innerHTML = `
    <div class="stats-grid">
      ${statCard(
        "Total Pembeli",
        buyers.length,
        "♙",
        "Akun pembeli dari Supabase"
      )}

      ${statCard(
        "Total Penjual Disetujui",
        sellers.filter(s => s.status === "Disetujui").length,
        "♧",
        "Penjual yang telah disetujui"
      )}

      ${statCard(
        "Total Produk",
        products.length,
        "▣",
        "Data produk masih contoh"
      )}

      ${statCard(
        "Total Pesanan",
        orders.length,
        "▤",
        "Data pesanan masih contoh"
      )}
    </div>

    <section class="panel">
      <div class="panel-header">
        <div>
          <h2>Pendaftaran Penjual Terbaru</h2>
          <p>Data profil penjual dari Supabase.</p>
        </div>

        <button class="btn btn-primary" data-page="approvals">
          Lihat Semua →
        </button>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>CALON PENJUAL</th>
              <th>NAMA USAHA</th>
              <th>TANGGAL DAFTAR</th>
              <th>STATUS</th>
              <th>TINDAKAN</th>
            </tr>
          </thead>

          <tbody>
            ${
              sellers
                .filter(s => s.status === "Menunggu")
                .slice(0, 5)
                .map(s => `
                  <tr>
                    <td>${personCell(s.name, s.email)}</td>
                    <td>${escapeHTML(s.business)}</td>
                    <td>${escapeHTML(s.date)}</td>
                    <td>${statusBadge(s.status)}</td>
                    <td>
                      <button class="btn btn-light" data-page="approvals">
                        Periksa
                      </button>
                    </td>
                  </tr>
                `).join("")
              ||
              `<tr>
                <td colspan="5" class="empty-state">
                  Tidak ada pendaftaran yang menunggu.
                </td>
              </tr>`
            }
          </tbody>
        </table>
      </div>

      <div class="panel-footer">
        <span>${getPendingCount()} pendaftaran menunggu persetujuan</span>
        <span>Data pembeli dan penjual dari Supabase</span>
      </div>
    </section>

    <div class="quick-grid">
      <div class="quick-card">
        <h3>Persetujuan Penjual</h3>
        <p>Periksa pendaftaran penjual sebelum memberikan akses berjualan.</p>
        <button class="btn btn-primary" data-page="approvals">
          Buka Persetujuan
        </button>
      </div>

      <div class="quick-card">
        <h3>Data Marketplace</h3>
        <p>Lihat profil pembeli dan penjual yang terdaftar.</p>
        <button class="btn btn-light" data-page="buyers">
          Lihat Pembeli
        </button>
      </div>
    </div>`;
}

/* ==================================================
   PERSETUJUAN PENJUAL
================================================== */

function renderApprovals() {
  pageContent.innerHTML = `
    <section class="panel">
      <div class="panel-header">
        <div>
          <h2>Daftar Pendaftaran Penjual</h2>
          <p>Persetujuan akan diperbarui ke database Supabase.</p>
        </div>

        <div class="panel-actions">
          <input
            id="searchInput"
            class="search-input"
            placeholder="Cari nama atau email..."
          >

          <select id="statusFilter" class="filter-select">
            <option value="Semua">Semua Status</option>
            <option value="Menunggu">Menunggu</option>
            <option value="Disetujui">Disetujui</option>
            <option value="Ditolak">Ditolak</option>
          </select>
        </div>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>CALON PENJUAL</th>
              <th>NAMA USAHA</th>
              <th>TANGGAL DAFTAR</th>
              <th>STATUS</th>
              <th>TINDAKAN</th>
            </tr>
          </thead>

          <tbody id="sellerTableBody"></tbody>
        </table>
      </div>

      <div class="panel-footer">
        <span id="sellerCount"></span>
        <span>Data Supabase</span>
      </div>
    </section>`;

  const searchInput = document.getElementById("searchInput");
  const statusFilter = document.getElementById("statusFilter");

  function updateTable() {
    const query = searchInput.value.toLowerCase().trim();
    const filter = statusFilter.value;

    const filtered = sellers.filter(seller => {
      const text =
        `${seller.name} ${seller.email} ${seller.business}`.toLowerCase();

      return text.includes(query) &&
        (filter === "Semua" || seller.status === filter);
    });

    document.getElementById("sellerTableBody").innerHTML =
      filtered.map(seller => `
        <tr>
          <td>${personCell(seller.name, seller.email)}</td>
          <td>${escapeHTML(seller.business)}</td>
          <td>${escapeHTML(seller.date)}</td>
          <td>${statusBadge(seller.status)}</td>

          <td>
            ${
              seller.status === "Menunggu"
                ? `
                  <div class="actions">
                    <button
                      class="btn btn-success"
                      data-action="approve"
                      data-id="${escapeHTML(seller.id)}"
                    >Setujui</button>

                    <button
                      class="btn btn-danger"
                      data-action="reject"
                      data-id="${escapeHTML(seller.id)}"
                    >Tolak</button>
                  </div>
                `
                : `<span class="stat-note">Tidak ada tindakan</span>`
            }
          </td>
        </tr>
      `).join("") ||
      `<tr>
        <td colspan="5" class="empty-state">
          Data tidak ditemukan.
        </td>
      </tr>`;

    document.getElementById("sellerCount").textContent =
      `${filtered.length} data ditampilkan · ${getPendingCount()} menunggu`;
  }

  searchInput.addEventListener("input", updateTable);
  statusFilter.addEventListener("change", updateTable);

  updateTable();
}

/* ==================================================
   TABEL UMUM
================================================== */

function renderSimpleTable(headers, rows, description = "Data tersedia.") {
  return `
    <section class="panel">
      <div class="panel-header">
        <div>
          <h2>Daftar Data</h2>
          <p>${escapeHTML(description)}</p>
        </div>

        <input
          id="genericSearch"
          class="search-input"
          placeholder="Cari data..."
        >
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>${headers.map(h => `<th>${h}</th>`).join("")}</tr>
          </thead>

          <tbody id="genericTableBody">
            ${
              rows.length
                ? rows.map(row =>
                    `<tr>${row.map(cell => `<td>${cell}</td>`).join("")}</tr>`
                  ).join("")
                : `<tr>
                    <td colspan="${headers.length}" class="empty-state">
                      Belum ada data.
                    </td>
                  </tr>`
            }
          </tbody>
        </table>
      </div>
    </section>`;
}

/* ==================================================
   NAVIGASI HALAMAN
================================================== */

function renderPage(page) {
  if (!pageInfo[page]) page = "dashboard";

  currentPage = page;

  const [title, description] = pageInfo[page];

  pageTitle.textContent = title;
  breadcrumbTitle.textContent = title;
  pageDescription.textContent = description;

  document.querySelectorAll(".nav-item").forEach(button => {
    button.classList.toggle("active", button.dataset.page === page);
  });

  if (page === "dashboard") {
    renderDashboard();

  } else if (page === "approvals") {
    renderApprovals();

  } else if (page === "buyers") {
    pageContent.innerHTML = renderSimpleTable(
      ["PEMBELI", "TANGGAL DAFTAR"],
      buyers.map(b => [
        personCell(b.name, b.email),
        escapeHTML(b.date)
      ]),
      "Data pembeli dari Supabase."
    );

  } else if (page === "sellers") {
    pageContent.innerHTML = renderSimpleTable(
      ["PENJUAL", "NAMA USAHA", "STATUS"],
      sellers.map(s => [
        personCell(s.name, s.email),
        escapeHTML(s.business),
        statusBadge(s.status)
      ]),
      "Data penjual dari Supabase."
    );

  } else if (page === "products") {
    pageContent.innerHTML = renderSimpleTable(
      ["NAMA PRODUK", "PENJUAL", "HARGA", "STATUS"],
      products.map(p => [
        escapeHTML(p.name),
        escapeHTML(p.seller),
        rupiah(p.price),
        statusBadge(p.status)
      ]),
      "Data produk masih contoh, belum terhubung ke Supabase."
    );

  } else if (page === "orders") {
    pageContent.innerHTML = renderSimpleTable(
      ["ID PESANAN", "PEMBELI", "PRODUK", "TOTAL", "STATUS"],
      orders.map(o => [
        escapeHTML(o.id),
        escapeHTML(o.buyer),
        escapeHTML(o.product),
        rupiah(o.total),
        statusBadge(o.status)
      ]),
      "Data pesanan masih contoh, belum terhubung ke Supabase."
    );

  } else if (page === "reports") {
    const total = orders.reduce((sum, order) => sum + order.total, 0);

    pageContent.innerHTML = `
      <div class="stats-grid">
        ${statCard("Total Pesanan", orders.length, "▤", "Data contoh")}
        ${statCard("Nilai Pesanan", rupiah(total), "Rp", "Data contoh")}
      </div>

      <section class="panel">
        <div class="panel-header">
          <div>
            <h2>Ringkasan Pesanan</h2>
            <p>Laporan ini belum berasal dari transaksi nyata.</p>
          </div>
        </div>

        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>PEMBELI</th>
                <th>TOTAL</th>
                <th>STATUS</th>
              </tr>
            </thead>

            <tbody>
              ${orders.map(o => `
                <tr>
                  <td>${escapeHTML(o.id)}</td>
                  <td>${escapeHTML(o.buyer)}</td>
                  <td>${rupiah(o.total)}</td>
                  <td>${statusBadge(o.status)}</td>
                </tr>
              `).join("")}
            </tbody>
          </table>
        </div>
      </section>`;
  }

  const genericSearch = document.getElementById("genericSearch");

  if (genericSearch) {
    genericSearch.addEventListener("input", () => {
      const query = genericSearch.value.toLowerCase();

      document.querySelectorAll("#genericTableBody tr").forEach(row => {
        row.style.display =
          row.textContent.toLowerCase().includes(query) ? "" : "none";
      });
    });
  }

  updateApprovalBadge();

  document.getElementById("sidebar")?.classList.remove("open");
}

/* ==================================================
   AKSI PERSETUJUAN / PENOLAKAN
================================================== */

async function updateSellerStatus(sellerId, action) {
  const seller = sellers.find(s => s.id === sellerId);

  if (!seller || seller.status !== "Menunggu") return;

  const accepted = action === "approve";

  const confirmed = window.confirm(
    `${accepted ? "Setujui" : "Tolak"} pendaftaran ${seller.name}?`
  );

  if (!confirmed) return;

  const newStatus = accepted ? "approved" : "rejected";

  const { data, error } = await supabaseClient
    .from("profiles")
    .update({ seller_status: newStatus })
    .eq("id", sellerId)
    .eq("role", "seller")
    .select("id, seller_status");

  if (error) {
    console.error("Gagal memperbarui status penjual:", error);

    showToast(
      "Gagal memperbarui status. Periksa kebijakan UPDATE RLS."
    );

    return;
  }

  if (!data || data.length === 0) {
    showToast(
      "Tidak ada data yang diperbarui. Periksa RLS dan status penjual."
    );

    return;
  }

  const loaded = await loadProfiles();

  if (!loaded) return;

  renderPage(currentPage);

  showToast(
    accepted
      ? "Penjual berhasil disetujui."
      : "Pendaftaran penjual berhasil ditolak."
  );
}

/* ==================================================
   EVENT NAVIGASI DAN AKSI
================================================== */

document.addEventListener("click", async event => {
  const pageButton = event.target.closest("[data-page]");

  if (pageButton) {
    // Jangan izinkan navigasi admin saat belum login.
    if (!adminApp || adminApp.hidden) return;

    renderPage(pageButton.dataset.page);
    return;
  }

  const actionButton = event.target.closest("[data-action]");

  if (actionButton) {
    if (!adminApp || adminApp.hidden) return;

    const action = actionButton.dataset.action;
    const sellerId = actionButton.dataset.id;

    if (action !== "approve" && action !== "reject") return;

    await updateSellerStatus(sellerId, action);
  }
});

/* ==================================================
   MENU MOBILE
================================================== */

document.getElementById("mobileMenu")?.addEventListener("click", () => {
  document.getElementById("sidebar")?.classList.toggle("open");
});

/* ==================================================
   LOGOUT
================================================== */

document.getElementById("logoutBtn")?.addEventListener("click", async () => {
  const confirmed = window.confirm("Yakin ingin keluar dari panel admin?");

  if (!confirmed) return;

  const { error } = await supabaseClient.auth.signOut();

  if (error) {
    console.error("Logout gagal:", error);
    showToast("Logout gagal. Silakan coba lagi.");
    return;
  }

  profiles = [];
  sellers = [];
  buyers = [];

  showLogin();
  showToast("Berhasil logout.");
});

/* ==================================================
   TANGGAL DAN INISIALISASI
================================================== */

const currentDate = document.getElementById("currentDate");

if (currentDate) {
  currentDate.textContent = new Intl.DateTimeFormat("id-ID", {
    day: "numeric",
    month: "long",
    year: "numeric"
  }).format(new Date());
}

// Jangan membuka dashboard sebelum memeriksa sesi dan role admin.
showLogin();

verifyAdmin().then(allowed => {
  if (allowed) {
    renderPage("dashboard");
  }
});