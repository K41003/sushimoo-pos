import React, { useState } from 'react';
import { 
  Plus, 
  Edit2, 
  Trash2, 
  Check, 
  X, 
  UtensilsCrossed, 
  Bookmark, 
  Grid,
  FilePlus,
  Power,
  RotateCcw
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Category, Product, Table } from '../types';

interface ManagementViewProps {
  categories: Category[];
  products: Product[];
  tables: Table[];
  onUpdateCategories: (categories: Category[]) => void;
  onUpdateProducts: (products: Product[]) => void;
  onUpdateTables: (tables: Table[]) => void;
}

export default function ManagementView({ 
  categories, 
  products, 
  tables, 
  onUpdateCategories, 
  onUpdateProducts, 
  onUpdateTables 
}: ManagementViewProps) {
  
  const [activeTab, setActiveTab] = useState<'products' | 'categories' | 'tables'>('products');

  // Modal forms states
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItemId, setEditingItemId] = useState<number | null>(null);

  // Form states: Category
  const [catName, setCatName] = useState('');
  const [catDesc, setCatDesc] = useState('');

  // Form states: Product
  const [prodName, setProdName] = useState('');
  const [prodPrice, setProdPrice] = useState('');
  const [prodCatId, setProdCatId] = useState<number>(categories[0]?.id_kategori || 1);
  const [prodStock, setProdStock] = useState('');

  // Form states: Table
  const [tabNumber, setTabNumber] = useState('');
  const [tabCapacity, setTabCapacity] = useState('');

  const openAddModal = () => {
    setEditingItemId(null);
    setIsModalOpen(true);
    
    // Reset forms
    setCatName('');
    setCatDesc('');
    setProdName('');
    setProdPrice('');
    setProdStock('50');
    setProdCatId(categories[0]?.id_kategori || 1);
    setTabNumber(`M0${tables.length + 1}`);
    setTabCapacity('4');
  };

  const openEditModal = (item: any) => {
    setEditingItemId(item.id_kategori || item.id_produk || item.id_meja);
    setIsModalOpen(true);

    if (activeTab === 'categories') {
      const c = item as Category;
      setCatName(c.nama_kategori);
      setCatDesc(c.deskripsi);
    } else if (activeTab === 'products') {
      const p = item as Product;
      setProdName(p.nama_produk);
      setProdPrice(p.harga.toString());
      setProdCatId(p.id_kategori);
      setProdStock(p.stok.toString());
    } else if (activeTab === 'tables') {
      const t = item as Table;
      setTabNumber(t.nomor_meja);
      setTabCapacity(t.kapasitas.toString());
    }
  };

  const handleFormSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (activeTab === 'categories') {
      if (!catName.trim()) return;
      if (editingItemId !== null) {
        // Edit category
        const updated = categories.map(c => 
          c.id_kategori === editingItemId 
            ? { ...c, nama_kategori: catName.trim(), deskripsi: catDesc.trim() } 
            : c
        );
        onUpdateCategories(updated);
      } else {
        // Add category
        const newCat: Category = {
          id_kategori: Date.now(),
          nama_kategori: catName.trim(),
          deskripsi: catDesc.trim(),
          status: 1
        };
        onUpdateCategories([...categories, newCat]);
      }
    } 
    
    else if (activeTab === 'products') {
      if (!prodName.trim()) return;
      const price = parseFloat(prodPrice);
      const stock = parseInt(prodStock);
      if (isNaN(price) || price < 0 || isNaN(stock) || stock < 0) {
        alert('Masukkan harga dan stok porsi yang valid.');
        return;
      }

      if (editingItemId !== null) {
        // Edit product
        const updated = products.map(p => 
          p.id_produk === editingItemId 
            ? { ...p, nama_produk: prodName.trim(), harga: price, id_kategori: prodCatId, stok: stock } 
            : p
        );
        onUpdateProducts(updated);
      } else {
        // Add product
        const newProd: Product = {
          id_produk: Date.now(),
          id_kategori: prodCatId,
          nama_produk: prodName.trim(),
          harga: price,
          status: 1,
          stok: stock
        };
        onUpdateProducts([...products, newProd]);
      }
    } 
    
    else if (activeTab === 'tables') {
      if (!tabNumber.trim()) return;
      const cap = parseInt(tabCapacity);
      if (isNaN(cap) || cap <= 0) {
        alert('Masukkan kapasitas kursi meja yang valid.');
        return;
      }

      if (editingItemId !== null) {
        // Edit table
        const updated = tables.map(t => 
          t.id_meja === editingItemId 
            ? { ...t, nomor_meja: tabNumber.trim().toUpperCase(), kapasitas: cap } 
            : t
        );
        onUpdateTables(updated);
      } else {
        // Add table
        const newTable: Table = {
          id_meja: Date.now(),
          nomor_meja: tabNumber.trim().toUpperCase(),
          kapasitas: cap,
          status: 'available'
        };
        onUpdateTables([...tables, newTable]);
      }
    }

    setIsModalOpen(false);
  };

  const toggleStatus = (id: number) => {
    if (activeTab === 'categories') {
      const updated = categories.map(c => 
        c.id_kategori === id ? { ...c, status: c.status === 1 ? 0 : 1 } : c
      );
      onUpdateCategories(updated);
    } else if (activeTab === 'products') {
      const updated = products.map(p => 
        p.id_produk === id ? { ...p, status: p.status === 1 ? 0 : 1 } : p
      );
      onUpdateProducts(updated);
    }
  };

  const deleteItem = (id: number) => {
    const confirmDel = window.confirm('Apakah Anda yakin ingin menghapus item ini?');
    if (!confirmDel) return;

    if (activeTab === 'categories') {
      const updated = categories.filter(c => c.id_kategori !== id);
      onUpdateCategories(updated);
    } else if (activeTab === 'products') {
      const updated = products.filter(p => p.id_produk !== id);
      onUpdateProducts(updated);
    } else if (activeTab === 'tables') {
      const updated = tables.filter(t => t.id_meja !== id);
      onUpdateTables(updated);
    }
  };

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
  };

  return (
    <div id="management-view" className="space-y-6">
      
      {/* Tab Selectors & Add Buttons */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 bg-white border border-slate-200 p-4 rounded-xl shadow-sm">
        <div className="flex bg-slate-100 p-1 rounded-lg">
          <button
            id="tab-products"
            onClick={() => setActiveTab('products')}
            className={`px-4 py-2 text-xs font-bold rounded-md flex items-center gap-2 transition-all ${activeTab === 'products' ? 'bg-[#1A1A1A] text-white' : 'text-slate-600 hover:text-slate-900'}`}
          >
            <Grid className="w-4 h-4" /> Kelola Produk
          </button>
          <button
            id="tab-categories"
            onClick={() => setActiveTab('categories')}
            className={`px-4 py-2 text-xs font-bold rounded-md flex items-center gap-2 transition-all ${activeTab === 'categories' ? 'bg-[#1A1A1A] text-white' : 'text-slate-600 hover:text-slate-900'}`}
          >
            <Bookmark className="w-4 h-4" /> Kelola Kategori
          </button>
          <button
            id="tab-tables"
            onClick={() => setActiveTab('tables')}
            className={`px-4 py-2 text-xs font-bold rounded-md flex items-center gap-2 transition-all ${activeTab === 'tables' ? 'bg-[#1A1A1A] text-white' : 'text-slate-600 hover:text-slate-900'}`}
          >
            <UtensilsCrossed className="w-4 h-4" /> Kelola Meja
          </button>
        </div>

        <button
          id="btn-add-item"
          onClick={openAddModal}
          className="px-4 py-2 bg-[#E63946] hover:bg-[#ff4d5a] text-white text-xs font-bold rounded flex items-center justify-center gap-1.5 transition-colors shadow"
        >
          <Plus className="w-4.5 h-4.5" /> 
          {activeTab === 'products' ? 'Tambah Produk' : activeTab === 'categories' ? 'Tambah Kategori' : 'Tambah Meja'}
        </button>
      </div>

      {/* TABLE/LIST PANELS */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden text-xs">
        {activeTab === 'products' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse" id="table-products">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
                  <th className="p-4">Nama Produk</th>
                  <th className="p-4">Kategori</th>
                  <th className="p-4">Harga</th>
                  <th className="p-4">Porsi Stok</th>
                  <th className="p-4">Status</th>
                  <th className="p-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {products.map(p => (
                  <tr key={p.id_produk} className="hover:bg-slate-50/50">
                    <td className="p-4 font-bold text-slate-950">{p.nama_produk}</td>
                    <td className="p-4 text-slate-500">
                      {categories.find(c => c.id_kategori === p.id_kategori)?.nama_kategori || 'Tak Berkategori'}
                    </td>
                    <td className="p-4 font-mono font-bold text-slate-900">{formatIDR(p.harga)}</td>
                    <td className="p-4 font-mono">{p.stok} pcs</td>
                    <td className="p-4">
                      <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${p.status === 1 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                        {p.status === 1 ? 'Aktif' : 'Nonaktif'}
                      </span>
                    </td>
                    <td className="p-4 text-right flex items-center justify-end gap-2">
                      <button onClick={() => toggleStatus(p.id_produk)} className="p-1 rounded text-slate-400 hover:text-slate-600" title="Toggle Aktif/Nonaktif">
                        <Power className="w-4 h-4" />
                      </button>
                      <button onClick={() => openEditModal(p)} className="p-1 rounded text-slate-400 hover:text-blue-600" title="Edit">
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button onClick={() => deleteItem(p.id_produk)} className="p-1 rounded text-slate-400 hover:text-rose-600" title="Hapus">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'categories' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse" id="table-categories">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
                  <th className="p-4">Nama Kategori</th>
                  <th className="p-4">Deskripsi</th>
                  <th className="p-4">Status</th>
                  <th className="p-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {categories.map(c => (
                  <tr key={c.id_kategori} className="hover:bg-slate-50/50">
                    <td className="p-4 font-bold text-slate-950">{c.nama_kategori}</td>
                    <td className="p-4 text-slate-500">{c.deskripsi || '-'}</td>
                    <td className="p-4">
                      <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${c.status === 1 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                        {c.status === 1 ? 'Aktif' : 'Nonaktif'}
                      </span>
                    </td>
                    <td className="p-4 text-right flex items-center justify-end gap-2">
                      <button onClick={() => toggleStatus(c.id_kategori)} className="p-1 rounded text-slate-400 hover:text-slate-600" title="Toggle Aktif">
                        <Power className="w-4 h-4" />
                      </button>
                      <button onClick={() => openEditModal(c)} className="p-1 rounded text-slate-400 hover:text-blue-600">
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button onClick={() => deleteItem(c.id_kategori)} className="p-1 rounded text-slate-400 hover:text-rose-600">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'tables' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse" id="table-tables">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
                  <th className="p-4">Nomor Meja</th>
                  <th className="p-4">Kapasitas Kursi</th>
                  <th className="p-4">Status Layanan</th>
                  <th className="p-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {tables.map(t => (
                  <tr key={t.id_meja} className="hover:bg-slate-50/50">
                    <td className="p-4 font-bold text-slate-950 font-mono">{t.nomor_meja}</td>
                    <td className="p-4 font-mono">{t.kapasitas} Kursi</td>
                    <td className="p-4">
                      <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${t.status === 'available' ? 'bg-emerald-100 text-emerald-800' : t.status === 'occupied' ? 'bg-amber-100 text-amber-800' : 'bg-slate-100 text-slate-700'}`}>
                        {t.status === 'available' ? 'Tersedia' : t.status === 'occupied' ? 'Terisi' : t.status}
                      </span>
                    </td>
                    <td className="p-4 text-right flex items-center justify-end gap-2">
                      <button onClick={() => {
                        const updated = tables.map(meja => 
                          meja.id_meja === t.id_meja 
                            ? { ...meja, status: meja.status === 'available' ? 'occupied' as const : 'available' as const } 
                            : meja
                        );
                        onUpdateTables(updated);
                      }} className="p-1 rounded text-slate-400 hover:text-slate-600" title="Toggle Keterisian Meja">
                        <RotateCcw className="w-4 h-4" />
                      </button>
                      <button onClick={() => openEditModal(t)} className="p-1 rounded text-slate-400 hover:text-blue-600">
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button onClick={() => deleteItem(t.id_meja)} className="p-1 rounded text-slate-400 hover:text-rose-600">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* CRUD MODAL */}
      <AnimatePresence>
        {isModalOpen && (
          <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="bg-white rounded-xl shadow-2xl p-6 max-w-md w-full relative border border-slate-100 text-xs"
            >
              <button
                id="crud-close"
                onClick={() => setIsModalOpen(false)}
                className="absolute top-4 right-4 p-1 rounded-full text-slate-400 hover:bg-slate-100"
              >
                <X className="w-5 h-5" />
              </button>

              <h3 className="text-sm font-bold text-slate-900 mb-4 flex items-center gap-1.5">
                <FilePlus className="w-4.5 h-4.5 text-[#E63946]" />
                {editingItemId !== null ? 'Ubah' : 'Tambah'} {activeTab === 'products' ? 'Produk' : activeTab === 'categories' ? 'Kategori' : 'Meja'}
              </h3>

              <form onSubmit={handleFormSubmit} className="space-y-4">
                {activeTab === 'categories' && (
                  <>
                    <div>
                      <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Nama Kategori</label>
                      <input
                        id="form-cat-name"
                        type="text"
                        required
                        value={catName}
                        onChange={e => setCatName(e.target.value)}
                        placeholder="Contoh: Ramen Jumbo"
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none focus:border-[#E63946]"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Deskripsi Singkat</label>
                      <textarea
                        id="form-cat-desc"
                        rows={2}
                        value={catDesc}
                        onChange={e => setCatDesc(e.target.value)}
                        placeholder="Deskripsi kategori..."
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none focus:border-[#E63946]"
                      />
                    </div>
                  </>
                )}

                {activeTab === 'products' && (
                  <>
                    <div>
                      <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Nama Menu Makanan/Minuman</label>
                      <input
                        id="form-prod-name"
                        type="text"
                        required
                        value={prodName}
                        onChange={e => setProdName(e.target.value)}
                        placeholder="Contoh: Ramen Curry Chicken"
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none"
                      />
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Harga Jual (Rp)</label>
                        <input
                          id="form-prod-price"
                          type="number"
                          required
                          value={prodPrice}
                          onChange={e => setProdPrice(e.target.value)}
                          placeholder="38000"
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none font-mono"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Porsi Stok Awal</label>
                        <input
                          id="form-prod-stock"
                          type="number"
                          required
                          value={prodStock}
                          onChange={e => setProdStock(e.target.value)}
                          placeholder="50"
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none font-mono"
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Pilih Kategori</label>
                      <select
                        id="form-prod-cat"
                        value={prodCatId}
                        onChange={e => setProdCatId(Number(e.target.value))}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-700"
                      >
                        {categories.map(c => (
                          <option key={c.id_kategori} value={c.id_kategori}>{c.nama_kategori}</option>
                        ))}
                      </select>
                    </div>
                  </>
                )}

                {activeTab === 'tables' && (
                  <>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Nomor Meja</label>
                        <input
                          id="form-tab-num"
                          type="text"
                          required
                          value={tabNumber}
                          onChange={e => setTabNumber(e.target.value)}
                          placeholder="M06"
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none font-mono font-bold"
                        />
                      </div>
                      <div>
                        <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Kapasitas Kursi</label>
                        <input
                          id="form-tab-cap"
                          type="number"
                          required
                          value={tabCapacity}
                          onChange={e => setTabCapacity(e.target.value)}
                          placeholder="4"
                          className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none font-mono"
                        />
                      </div>
                    </div>
                  </>
                )}

                <button
                  id="crud-submit"
                  type="submit"
                  className="w-full py-2.5 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-xs uppercase tracking-widest rounded transition-colors shadow mt-2"
                >
                  Simpan Perubahan
                </button>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
}
