import React, { useState, useMemo } from 'react';
import { 
  Search, 
  ShoppingCart, 
  Plus, 
  Minus, 
  Trash2, 
  Utensils, 
  User, 
  Printer, 
  Check, 
  AlertCircle,
  X,
  CreditCard,
  QrCode,
  DollarSign
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Category, Product, Table, Transaction, TransactionDetail, PaymentMethod, Shift } from '../types';

interface PosViewProps {
  categories: Category[];
  products: Product[];
  tables: Table[];
  paymentMethods: PaymentMethod[];
  activeShift: Shift | null;
  onUpdateProducts: (updatedProducts: Product[]) => void;
  onUpdateTables: (updatedTables: Table[]) => void;
  onCreateTransaction: (transaction: Transaction) => void;
  currentUser: { nama: string; id_user: number };
}

interface CartItem {
  product: Product;
  qty: number;
}

export default function PosView({ 
  categories, 
  products, 
  tables, 
  paymentMethods, 
  activeShift,
  onUpdateProducts,
  onUpdateTables,
  onCreateTransaction,
  currentUser
}: PosViewProps) {
  
  const [selectedCategory, setSelectedCategory] = useState<number | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTableId, setSelectedTableId] = useState<number>(0); // 0 = Takeaway
  const [cart, setCart] = useState<CartItem[]>([]);
  
  // Checkout flow state
  const [isCheckingOut, setIsCheckingOut] = useState(false);
  const [selectedMethodId, setSelectedMethodId] = useState<number>(1); // 1 = Cash
  const [cashReceived, setCashReceived] = useState<string>('');
  const [showReceipt, setShowReceipt] = useState<Transaction | null>(null);

  // Filter products based on search and category
  const filteredProducts = useMemo(() => {
    return products.filter(p => {
      const matchCategory = selectedCategory === null || p.id_kategori === selectedCategory;
      const matchSearch = p.nama_produk.toLowerCase().includes(searchQuery.toLowerCase());
      const matchActive = p.status === 1;
      return matchCategory && matchSearch && matchActive;
    });
  }, [products, selectedCategory, searchQuery]);

  // Cart operations
  const addToCart = (product: Product) => {
    if (product.stok <= 0) return;
    
    setCart(prev => {
      const existing = prev.find(item => item.product.id_produk === product.id_produk);
      if (existing) {
        if (existing.qty >= product.stok) return prev; // Limit to stock
        return prev.map(item => 
          item.product.id_produk === product.id_produk 
            ? { ...item, qty: item.qty + 1 } 
            : item
        );
      }
      return [...prev, { product, qty: 1 }];
    });
  };

  const updateQty = (productId: number, delta: number) => {
    setCart(prev => {
      return prev.map(item => {
        if (item.product.id_produk === productId) {
          const newQty = item.qty + delta;
          if (newQty <= 0) return null;
          if (newQty > item.product.stok) return item; // limit to stock
          return { ...item, qty: newQty };
        }
        return item;
      }).filter((item): item is CartItem => item !== null);
    });
  };

  const removeFromCart = (productId: number) => {
    setCart(prev => prev.filter(item => item.product.id_produk !== productId));
  };

  const clearCart = () => {
    setCart([]);
  };

  // Calculations
  const subtotal = cart.reduce((sum, item) => sum + (item.product.harga * item.qty), 0);
  const tax = subtotal * 0.10; // 10% PPN
  const serviceCharge = subtotal * 0.05; // 5% Service Charge
  const total = subtotal + tax + serviceCharge;

  // Change computation
  const change = useMemo(() => {
    if (selectedMethodId !== 1) return 0; // QRIS/Debit has exact change
    const cash = parseFloat(cashReceived);
    if (isNaN(cash) || cash < total) return 0;
    return cash - total;
  }, [selectedMethodId, cashReceived, total]);

  const canCheckout = cart.length > 0 && activeShift !== null;

  const handleCheckoutSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!canCheckout || !activeShift) return;

    const parsedCashReceived = selectedMethodId === 1 ? parseFloat(cashReceived) : total;
    if (selectedMethodId === 1 && (isNaN(parsedCashReceived) || parsedCashReceived < total)) {
      alert('Uang tunai yang diterima kurang dari total pembayaran.');
      return;
    }

    // Generate Invoice Number
    const dateStr = new Date().toISOString().replace(/[-:T.]/g, '').substring(2, 10);
    const randSuffix = Math.floor(100 + Math.random() * 900);
    const invoiceNumber = `SM-${dateStr}-${randSuffix}`;

    // Create Transaction details
    const details: TransactionDetail[] = cart.map((item, idx) => ({
      id_detail: Date.now() + idx,
      id_transaksi: Date.now(),
      id_produk: item.product.id_produk,
      nama_produk: item.product.nama_produk,
      qty: item.qty,
      harga: item.product.harga,
      subtotal: item.product.harga * item.qty
    }));

    // Create main Transaction
    const transaction: Transaction = {
      id_transaksi: Date.now(),
      invoice_number: invoiceNumber,
      id_shift: activeShift.id_shift,
      id_user: currentUser.id_user,
      id_meja: selectedTableId,
      tanggal: new Date().toISOString(),
      total: total,
      status: 'paid',
      details,
      id_metode: selectedMethodId,
      uang_diterima: parsedCashReceived,
      kembalian: selectedMethodId === 1 ? parsedCashReceived - total : 0,
      waktu_bayar: new Date().toISOString()
    };

    // Update stocks
    const updatedProducts = products.map(p => {
      const cartItem = cart.find(c => c.product.id_produk === p.id_produk);
      if (cartItem) {
        return { ...p, stok: p.stok - cartItem.qty };
      }
      return p;
    });

    // Update table status if dine-in
    let updatedTables = [...tables];
    if (selectedTableId > 0) {
      updatedTables = tables.map(t => 
        t.id_meja === selectedTableId 
          ? { ...t, status: 'occupied' as const } 
          : t
      );
    }

    onUpdateProducts(updatedProducts);
    onUpdateTables(updatedTables);
    onCreateTransaction(transaction);

    // Prompt receipt display and reset
    setShowReceipt(transaction);
    setCart([]);
    setIsCheckingOut(false);
    setCashReceived('');
    setSelectedTableId(0);
  };

  const selectedTableName = useMemo(() => {
    if (selectedTableId === 0) return 'Takeaway (Bawa Pulang)';
    const tObj = tables.find(t => t.id_meja === selectedTableId);
    return tObj ? `Meja ${tObj.nomor_meja}` : `Meja #${selectedTableId}`;
  }, [selectedTableId, tables]);

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
  };

  return (
    <div id="pos-layout" className="grid grid-cols-1 lg:grid-cols-12 gap-6 min-h-[calc(100vh-140px)] items-stretch">
      {/* LEFT PANEL: Categories, search, foods grid (8 cols) */}
      <div className="lg:col-span-8 flex flex-col space-y-4">
        
        {/* Table & Dine-in Selection Banner */}
        <div className="bg-white border border-slate-200 p-4 rounded-xl shadow-sm flex flex-wrap items-center justify-between gap-3">
          <div className="flex items-center gap-2.5">
            <Utensils className="w-5 h-5 text-[#E63946]" />
            <div>
              <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Lokasi Layanan</p>
              <p className="text-sm font-bold text-slate-900">{selectedTableName}</p>
            </div>
          </div>
          
          <div className="flex flex-wrap gap-2">
            <button
              id="pos-select-takeaway"
              onClick={() => setSelectedTableId(0)}
              className={`px-3 py-1.5 rounded text-xs font-semibold border transition-all ${selectedTableId === 0 ? 'bg-[#E63946] border-[#E63946] text-white' : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'}`}
            >
              Takeaway
            </button>
            {tables.map(t => (
              <button
                key={t.id_meja}
                id={`pos-select-table-${t.nomor_meja}`}
                onClick={() => setSelectedTableId(t.id_meja)}
                className={`px-3 py-1.5 rounded text-xs font-semibold border flex items-center gap-1.5 transition-all ${selectedTableId === t.id_meja ? 'bg-[#E63946] border-[#E63946] text-white' : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'}`}
              >
                <span>{t.nomor_meja}</span>
                <span className={`w-1.5 h-1.5 rounded-full ${t.status === 'occupied' ? 'bg-amber-500' : 'bg-emerald-500'}`} />
              </button>
            ))}
          </div>
        </div>

        {/* Categories Scroller + Search Bar */}
        <div className="flex flex-col sm:flex-row gap-3 items-stretch sm:items-center justify-between">
          {/* Scrollable Categories List */}
          <div className="flex items-center gap-2 overflow-x-auto pb-1 shrink-0 max-w-full">
            <button
              id="pos-cat-all"
              onClick={() => setSelectedCategory(null)}
              className={`px-3.5 py-1.5 rounded-full text-xs font-semibold tracking-wide whitespace-nowrap transition-all border ${selectedCategory === null ? 'bg-[#1A1A1A] border-[#1A1A1A] text-white' : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'}`}
            >
              Semua Menu
            </button>
            {categories.map(cat => (
              <button
                key={cat.id_kategori}
                id={`pos-cat-${cat.id_kategori}`}
                onClick={() => setSelectedCategory(cat.id_kategori)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-semibold tracking-wide whitespace-nowrap transition-all border ${selectedCategory === cat.id_kategori ? 'bg-[#1A1A1A] border-[#1A1A1A] text-white' : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'}`}
              >
                {cat.nama_kategori}
              </button>
            ))}
          </div>

          {/* Search bar */}
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input
              id="pos-search"
              type="text"
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              placeholder="Cari sushi, ramen, ocha..."
              className="w-full pl-9 pr-4 py-2 bg-white border border-slate-200 rounded-lg text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:border-[#E63946]"
            />
          </div>
        </div>

        {/* Shift Offline Warning */}
        {activeShift === null && (
          <div className="bg-amber-50 border border-amber-200 p-3.5 rounded-xl flex items-center gap-2.5 text-amber-800 text-xs shadow-sm">
            <AlertCircle className="w-5 h-5 text-amber-600 shrink-0" />
            <p className="font-medium">Shift kasir belum dibuka! Anda tidak dapat melakukan pembayaran transaksi sampai shift dibuka oleh Kasir.</p>
          </div>
        )}

        {/* Foods Grid Scrollbox */}
        <div className="flex-1 overflow-y-auto max-h-[calc(100vh-280px)] pr-1 pb-4">
          {filteredProducts.length === 0 ? (
            <div className="bg-white border border-slate-200 rounded-xl p-16 text-center text-slate-400 font-mono text-xs">
              Tidak ada menu yang cocok atau aktif.
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4">
              {filteredProducts.map(p => {
                const cartQty = cart.find(item => item.product.id_produk === p.id_produk)?.qty || 0;
                const isOutOfStock = p.stok <= 0;
                
                return (
                  <motion.div
                    key={p.id_produk}
                    id={`product-card-${p.id_produk}`}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => !isOutOfStock && addToCart(p)}
                    className={`bg-white border p-4 rounded-xl shadow-sm relative flex flex-col justify-between h-44 cursor-pointer select-none transition-all ${cartQty > 0 ? 'ring-2 ring-[#E63946] border-transparent' : 'border-slate-200 hover:border-slate-300'} ${isOutOfStock ? 'opacity-50 cursor-not-allowed bg-slate-50' : ''}`}
                  >
                    {/* Badge Category Tag */}
                    <div className="text-[9px] text-[#E63946] font-extrabold uppercase tracking-widest font-mono">
                      {categories.find(c => c.id_kategori === p.id_kategori)?.nama_kategori}
                    </div>

                    <div className="my-2 flex-1 flex flex-col justify-center">
                      <p className="font-bold text-slate-900 text-sm leading-tight line-clamp-2">{p.nama_produk}</p>
                      <p className="text-slate-800 text-xs font-mono font-semibold mt-1">{formatIDR(p.harga)}</p>
                    </div>

                    <div className="flex items-center justify-between border-t border-slate-100 pt-2 text-[10px] font-mono">
                      <span className={`${p.stok < 10 ? 'text-amber-600 font-bold' : 'text-slate-500'}`}>
                        {isOutOfStock ? 'Stok Habis' : `Stok: ${p.stok}`}
                      </span>
                      {cartQty > 0 && (
                        <span className="bg-[#E63946] text-white px-2 py-0.5 rounded font-bold text-[10px]">
                          {cartQty}x
                        </span>
                      )}
                    </div>
                  </motion.div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* RIGHT PANEL: Cart details & billing sidebar (4 cols) */}
      <div className="lg:col-span-4 bg-white border border-slate-200 rounded-xl shadow-sm p-4 flex flex-col justify-between min-h-[calc(100vh-210px)] relative">
        <div className="flex flex-col flex-1">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-3">
            <h3 className="font-bold text-slate-900 text-sm flex items-center gap-2">
              <ShoppingCart className="w-4 h-4 text-[#E63946]" /> Keranjang Belanja
            </h3>
            {cart.length > 0 && (
              <button onClick={clearCart} className="text-xs text-rose-600 font-bold hover:underline">
                Kosongkan
              </button>
            )}
          </div>

          {/* Cart items scrollbox */}
          <div className="flex-1 overflow-y-auto max-h-[calc(100vh-450px)] pr-1 space-y-3">
            {cart.length === 0 ? (
              <div className="h-44 flex flex-col items-center justify-center text-slate-400 font-mono text-xs gap-2">
                <Utensils className="w-8 h-8 text-slate-300" />
                <span>Keranjang masih kosong</span>
              </div>
            ) : (
              cart.map(item => (
                <div key={item.product.id_produk} className="flex items-center justify-between bg-slate-50 p-2.5 rounded border border-slate-100 gap-2">
                  <div className="flex-1 min-w-0">
                    <p className="font-bold text-slate-800 text-xs truncate">{item.product.nama_produk}</p>
                    <p className="text-[10px] text-slate-500 font-mono">{formatIDR(item.product.harga)}/pcs</p>
                  </div>
                  
                  {/* Steppers */}
                  <div className="flex items-center gap-1 shrink-0">
                    <button
                      onClick={() => updateQty(item.product.id_produk, -1)}
                      className="p-1 rounded bg-white hover:bg-slate-100 border border-slate-200 text-slate-700"
                    >
                      <Minus className="w-3 h-3" />
                    </button>
                    <span className="font-mono text-xs font-bold w-6 text-center">{item.qty}</span>
                    <button
                      onClick={() => updateQty(item.product.id_produk, 1)}
                      className="p-1 rounded bg-white hover:bg-slate-100 border border-slate-200 text-slate-700"
                    >
                      <Plus className="w-3 h-3" />
                    </button>
                    <button
                      onClick={() => removeFromCart(item.product.id_produk)}
                      className="p-1 rounded text-rose-600 hover:bg-rose-50 border border-transparent ml-1"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Calculations Block */}
        <div className="border-t border-slate-100 pt-3 mt-4 space-y-2 text-xs font-medium">
          <div className="flex justify-between text-slate-500">
            <span>Subtotal</span>
            <span className="font-mono">{formatIDR(subtotal)}</span>
          </div>
          <div className="flex justify-between text-slate-500">
            <span>PPN (10%)</span>
            <span className="font-mono">{formatIDR(tax)}</span>
          </div>
          <div className="flex justify-between text-slate-500">
            <span>Service Charge (5%)</span>
            <span className="font-mono">{formatIDR(serviceCharge)}</span>
          </div>
          <div className="flex justify-between text-slate-900 font-bold text-sm border-t border-slate-100 pt-2">
            <span>Total Bayar</span>
            <span className="font-mono text-[#E63946]">{formatIDR(total)}</span>
          </div>

          {activeShift !== null ? (
            <button
              id="pos-btn-checkout"
              disabled={cart.length === 0}
              onClick={() => setIsCheckingOut(true)}
              className="w-full py-3 bg-[#1A1A1A] hover:bg-slate-900 text-white font-bold text-xs uppercase tracking-wider rounded transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Proses Pembayaran ({cart.length} Item)
            </button>
          ) : (
            <div className="text-center p-2 bg-amber-50 text-amber-700 text-[10px] font-bold rounded">
              Buka Shift Kasir untuk melakukan Checkout
            </div>
          )}
        </div>

        {/* CHECKOUT POPUP MODAL */}
        <AnimatePresence>
          {isCheckingOut && (
            <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
              <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                className="bg-white rounded-xl shadow-2xl p-6 max-w-md w-full relative border border-slate-100"
              >
                <button
                  id="checkout-close"
                  onClick={() => setIsCheckingOut(false)}
                  className="absolute top-4 right-4 p-1 rounded-full text-slate-400 hover:bg-slate-100"
                >
                  <X className="w-5 h-5" />
                </button>

                <h3 className="text-base font-bold text-slate-900 mb-2">Konfirmasi Pembayaran</h3>
                <p className="text-slate-500 text-xs mb-4">Pilih metode pembayaran dan masukkan jumlah uang yang diterima.</p>

                <form onSubmit={handleCheckoutSubmit} className="space-y-4">
                  <div>
                    <label className="block text-xs uppercase tracking-wider text-slate-500 font-bold mb-1.5">Metode Bayar</label>
                    <div className="grid grid-cols-3 gap-2">
                      <button
                        type="button"
                        id="checkout-method-cash"
                        onClick={() => { setSelectedMethodId(1); setCashReceived(''); }}
                        className={`py-3.5 rounded border text-xs font-bold flex flex-col items-center justify-center gap-1.5 transition-all ${selectedMethodId === 1 ? 'border-[#E63946] bg-rose-50/40 text-[#E63946]' : 'border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <DollarSign className="w-4 h-4" />
                        Cash (Tunai)
                      </button>
                      <button
                        type="button"
                        id="checkout-method-qris"
                        onClick={() => setSelectedMethodId(2)}
                        className={`py-3.5 rounded border text-xs font-bold flex flex-col items-center justify-center gap-1.5 transition-all ${selectedMethodId === 2 ? 'border-[#E63946] bg-rose-50/40 text-[#E63946]' : 'border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <QrCode className="w-4 h-4" />
                        QRIS Scan
                      </button>
                      <button
                        type="button"
                        id="checkout-method-debit"
                        onClick={() => setSelectedMethodId(3)}
                        className={`py-3.5 rounded border text-xs font-bold flex flex-col items-center justify-center gap-1.5 transition-all ${selectedMethodId === 3 ? 'border-[#E63946] bg-rose-50/40 text-[#E63946]' : 'border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <CreditCard className="w-4 h-4" />
                        Kartu Debit
                      </button>
                    </div>
                  </div>

                  {/* Pricing Overview */}
                  <div className="bg-slate-50 p-4 rounded-lg border border-slate-100 font-mono text-xs text-slate-600 space-y-1">
                    <div className="flex justify-between">
                      <span>Total Tagihan:</span>
                      <span className="font-bold text-slate-900">{formatIDR(total)}</span>
                    </div>
                    {selectedMethodId === 1 && cashReceived && (
                      <div className="flex justify-between border-t border-slate-200 pt-1 mt-1 text-[11px]">
                        <span>Kembalian:</span>
                        <span className={`font-bold ${change >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                          {change >= 0 ? formatIDR(change) : 'Uang Kurang'}
                        </span>
                      </div>
                    )}
                  </div>

                  {/* Cash Received input */}
                  {selectedMethodId === 1 && (
                    <div>
                      <label className="block text-xs uppercase tracking-wider text-slate-500 font-bold mb-1">Uang Diterima (Tunai)</label>
                      <input
                        id="checkout-cash-received"
                        type="number"
                        required
                        value={cashReceived}
                        onChange={e => setCashReceived(e.target.value)}
                        placeholder="Contoh: 100000"
                        className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded focus:border-[#E63946] focus:outline-none text-slate-900 font-mono text-sm"
                      />
                    </div>
                  )}

                  <button
                    type="submit"
                    id="checkout-submit"
                    disabled={selectedMethodId === 1 && (!cashReceived || change < 0)}
                    className="w-full py-3 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-xs uppercase tracking-widest rounded transition-colors disabled:opacity-50 disabled:cursor-not-allowed mt-2"
                  >
                    Bayar & Selesaikan Order
                  </button>
                </form>
              </motion.div>
            </div>
          )}
        </AnimatePresence>

        {/* PRINT RECEIPT PREVIEW DIALOG MODAL */}
        <AnimatePresence>
          {showReceipt && (
            <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
              <motion.div
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 15 }}
                className="bg-white rounded-xl shadow-2xl p-6 max-w-sm w-full relative border border-slate-100 flex flex-col max-h-[90vh]"
              >
                <div className="flex-1 overflow-y-auto pr-1">
                  {/* Sushi Theme Stamp */}
                  <div className="text-center mb-4 border-b border-dashed border-slate-300 pb-4">
                    <p className="text-xl font-bold tracking-widest font-serif">SUSHIMOO</p>
                    <p className="text-[10px] text-slate-500 uppercase tracking-widest font-mono mt-0.5">Zen Japanese Dining</p>
                    <p className="text-[9px] text-slate-400 font-mono">Grand Indonesia Mall, Lt. 3 &bull; Jakarta</p>
                  </div>

                  {/* Invoice Meta */}
                  <div className="font-mono text-[10px] text-slate-600 space-y-1 border-b border-dashed border-slate-300 pb-3 mb-3">
                    <div className="flex justify-between">
                      <span>No Invoice:</span>
                      <span className="font-bold text-slate-950">{showReceipt.invoice_number}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Tanggal:</span>
                      <span>{new Date(showReceipt.tanggal).toLocaleString('id-ID', { dateStyle: 'short', timeStyle: 'short' })}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Kasir:</span>
                      <span>{currentUser.nama}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Layanan:</span>
                      <span>{showReceipt.id_meja === 0 ? 'Bawa Pulang (Takeaway)' : `Dine In — Meja ${tables.find(t => t.id_meja === showReceipt.id_meja)?.nomor_meja}`}</span>
                    </div>
                  </div>

                  {/* Cart Details */}
                  <div className="space-y-2 border-b border-dashed border-slate-300 pb-3 mb-3 font-mono text-[10px] text-slate-700">
                    {showReceipt.details.map(item => (
                      <div key={item.id_detail}>
                        <div className="flex justify-between font-bold text-slate-900">
                          <span>{item.nama_produk}</span>
                          <span>{formatIDR(item.subtotal)}</span>
                        </div>
                        <div className="text-[9px] text-slate-500">
                          {item.qty} pcs x {formatIDR(item.harga)}
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* Calculations */}
                  <div className="font-mono text-[10px] text-slate-600 space-y-1 pb-3 mb-3 border-b border-dashed border-slate-300">
                    <div className="flex justify-between">
                      <span>Subtotal</span>
                      <span>{formatIDR(showReceipt.total / 1.15)}</span> {/* rough pre-tax calculation */}
                    </div>
                    <div className="flex justify-between">
                      <span>PPN (10%)</span>
                      <span>{formatIDR((showReceipt.total / 1.15) * 0.1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Service (5%)</span>
                      <span>{formatIDR((showReceipt.total / 1.15) * 0.05)}</span>
                    </div>
                    <div className="flex justify-between font-bold text-slate-950 text-xs border-t border-dotted border-slate-200 pt-1 mt-1">
                      <span>TOTAL</span>
                      <span>{formatIDR(showReceipt.total)}</span>
                    </div>
                  </div>

                  {/* Payment Meta */}
                  <div className="font-mono text-[10px] text-slate-600 space-y-1 pb-3 mb-1 text-center">
                    <p className="font-bold text-slate-950 uppercase tracking-widest text-[9px] mb-1">Detail Pembayaran</p>
                    <p>Metode Bayar: {paymentMethods.find(m => m.id_metode === showReceipt.id_metode)?.nama_metode}</p>
                    {showReceipt.id_metode === 1 && (
                      <>
                        <p>Bayar: {formatIDR(showReceipt.uang_diterima || 0)}</p>
                        <p>Kembali: {formatIDR(showReceipt.kembalian || 0)}</p>
                      </>
                    )}
                  </div>

                  <div className="text-center mt-6 text-[10px] text-slate-400 font-serif border-t border-dashed border-slate-200 pt-4 pb-2">
                    <p className="italic">Gochisousama Deshita!</p>
                    <p className="mt-1 font-sans text-[8px] uppercase tracking-widest font-semibold">Terima Kasih Atas Kunjungan Anda</p>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t border-slate-100 flex gap-2">
                  <button
                    id="receipt-print-confirm"
                    onClick={() => setShowReceipt(null)}
                    className="flex-1 py-2.5 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-xs uppercase tracking-widest rounded flex items-center justify-center gap-1.5 shadow transition-colors"
                  >
                    <Check className="w-4 h-4" /> Selesai
                  </button>
                  <button
                    onClick={() => {
                      alert('Simulasi: Mencetak struk POS via Blue Thermal Printer...');
                    }}
                    className="p-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded border border-slate-200"
                    title="Print struk"
                  >
                    <Printer className="w-4 h-4" />
                  </button>
                </div>
              </motion.div>
            </div>
          )}
        </AnimatePresence>

      </div>
    </div>
  );
}
