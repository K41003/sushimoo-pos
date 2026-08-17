import React, { useState, useEffect } from 'react';
import { 
  ShoppingBag, 
  LayoutDashboard, 
  Clock, 
  Lock, 
  Settings, 
  FileText, 
  LogOut, 
  User, 
  Activity,
  CheckCircle,
  HelpCircle,
  Inbox,
  AlertTriangle,
  MapPin,
  Flame,
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

// Data & types
import { 
  User as UserType, 
  Category, 
  Product, 
  Table, 
  PaymentMethod, 
  Shift, 
  Transaction, 
  Expense, 
  Closing, 
  ActivityLog 
} from './types';
import { 
  getStorage, 
  setStorage, 
  initializeDatabase, 
  INITIAL_PAYMENT_METHODS 
} from './data';

// Components
import Login from './components/Login';
import DashboardView from './components/DashboardView';
import PosView from './components/PosView';
import ShiftView from './components/ShiftView';
import ClosingView from './components/ClosingView';
import ManagementView from './components/ManagementView';
import ReportView from './components/ReportView';

export default function App() {
  // App states
  const [currentUser, setCurrentUser] = useState<UserType | null>(null);
  const [activeTab, setActiveTab] = useState<string>('pos');

  // Database lists
  const [categories, setCategories] = useState<Category[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [tables, setTables] = useState<Table[]>([]);
  const [paymentMethods, setPaymentMethods] = useState<PaymentMethod[]>([]);
  const [shifts, setShifts] = useState<Shift[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [closings, setClosings] = useState<Closing[]>([]);
  const [logs, setLogs] = useState<ActivityLog[]>([]);

  // 1. Initialize DB and load data from localStorage on mount
  useEffect(() => {
    initializeDatabase();
    
    // Load lists
    setCategories(getStorage<Category[]>('categories', []));
    setProducts(getStorage<Product[]>('products', []));
    setTables(getStorage<Table[]>('tables', []));
    setPaymentMethods(getStorage<PaymentMethod[]>('payment_methods', INITIAL_PAYMENT_METHODS));
    setShifts(getStorage<Shift[]>('shifts', []));
    setTransactions(getStorage<Transaction[]>('transactions', []));
    setExpenses(getStorage<Expense[]>('expenses', []));
    setClosings(getStorage<Closing[]>('closings', []));
    setLogs(getStorage<ActivityLog[]>('logs', []));

    // Auto load session if exists
    const storedUser = localStorage.getItem('sushimoo_active_user');
    if (storedUser) {
      try {
        setCurrentUser(JSON.parse(storedUser) as UserType);
      } catch (e) {
        localStorage.removeItem('sushimoo_active_user');
      }
    }
  }, []);

  // 2. Compute active shift
  const activeShift = React.useMemo(() => {
    return shifts.find(s => s.status === 'open') || null;
  }, [shifts]);

  // Logging Helper
  const appendLog = (activity: string, userId?: number) => {
    const newLog: ActivityLog = {
      id_log: Date.now(),
      id_user: userId || currentUser?.id_user,
      aktivitas: activity,
      ip_address: '127.0.0.1',
      created_at: new Date().toISOString()
    };
    const updatedLogs = [...logs, newLog];
    setLogs(updatedLogs);
    setStorage('logs', updatedLogs);
  };

  // State update & localStorage sync helpers
  const updateCategories = (updated: Category[]) => {
    setCategories(updated);
    setStorage('categories', updated);
  };

  const updateProducts = (updated: Product[]) => {
    setProducts(updated);
    setStorage('products', updated);
  };

  const updateTables = (updated: Table[]) => {
    setTables(updated);
    setStorage('tables', updated);
  };

  // User Actions
  const handleLogin = (user: UserType) => {
    setCurrentUser(user);
    localStorage.setItem('sushimoo_active_user', JSON.stringify(user));
    
    // Adjust active tab based on role
    if (user.id_role === 1) {
      setActiveTab('dashboard'); // Admins go to Dashboard first
    } else {
      setActiveTab('pos'); // Cashiers go to Cashier POS first
    }

    appendLog(`User ${user.nama} berhasil login (${user.id_role === 1 ? 'Admin' : 'Kasir'})`, user.id_user);
  };

  const handleLogout = () => {
    if (currentUser) {
      appendLog(`User ${currentUser.nama} logout dari sistem`);
    }
    setCurrentUser(null);
    localStorage.removeItem('sushimoo_active_user');
  };

  // Shift & Cash Drawer operations
  const handleOpenShift = (startingCash: number) => {
    if (!currentUser) return;
    
    const newShift: Shift = {
      id_shift: Date.now(),
      id_user: currentUser.id_user,
      open_time: new Date().toISOString(),
      petty_cash: startingCash,
      status: 'open'
    };

    const updatedShifts = [...shifts, newShift];
    setShifts(updatedShifts);
    setStorage('shifts', updatedShifts);
    
    appendLog(`Sesi Shift Baru dibuka oleh ${currentUser.nama} dengan modal awal ${new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(startingCash)}`);
  };

  const handleCloseShift = (actualCash: number, closingData: Closing) => {
    if (!currentUser || !activeShift) return;

    // Update active shift to closed
    const updatedShifts = shifts.map(s => 
      s.id_shift === activeShift.id_shift 
        ? { ...s, status: 'closed' as const, close_time: new Date().toISOString(), actual_cash: actualCash } 
        : s
    );
    setShifts(updatedShifts);
    setStorage('shifts', updatedShifts);

    // Append to closings
    const updatedClosings = [...closings, closingData];
    setClosings(updatedClosings);
    setStorage('closings', updatedClosings);

    // Release all tables back to available on close shift
    const updatedTables = tables.map(t => ({ ...t, status: 'available' as const }));
    setTables(updatedTables);
    setStorage('tables', updatedTables);

    appendLog(`Sesi Shift #${activeShift.id_shift} resmi ditutup oleh ${currentUser.nama}. Uang fisik laci: Rp ${actualCash.toLocaleString('id-ID')}`);
  };

  // Transaction checkout
  const handleCreateTransaction = (transaction: Transaction) => {
    const updatedTx = [...transactions, transaction];
    setTransactions(updatedTx);
    setStorage('transactions', updatedTx);

    appendLog(`Transaksi sukses dicatat. Invoice: ${transaction.invoice_number}, Total: Rp ${transaction.total.toLocaleString('id-ID')}`);
  };

  // Voiding order
  const handleVoidTransaction = (id: number, reason: string) => {
    // 1. Locate transaction
    const tx = transactions.find(t => t.id_transaksi === id);
    if (!tx) return;

    // 2. Change status to cancelled
    const updatedTx = transactions.map(t => 
      t.id_transaksi === id 
        ? { ...t, status: 'cancelled' as const, void_reason: reason } 
        : t
    );
    setTransactions(updatedTx);
    setStorage('transactions', updatedTx);

    // 3. Restore product stocks
    const updatedProducts = products.map(p => {
      const detailItem = tx.details.find(d => d.id_produk === p.id_produk);
      if (detailItem) {
        return { ...p, stok: p.stok + detailItem.qty };
      }
      return p;
    });
    setProducts(updatedProducts);
    setStorage('products', updatedProducts);

    // 4. Reset table status if dine-in
    if (tx.id_meja > 0) {
      const updatedTables = tables.map(t => 
        t.id_meja === tx.id_meja ? { ...t, status: 'available' as const } : t
      );
      setTables(updatedTables);
      setStorage('tables', updatedTables);
    }

    appendLog(`VOID Otorisasi Admin: Invoice ${tx.invoice_number} berhasil dibatalkan. Alasan: ${reason}`);
  };

  // Log Petty Expense
  const handleAddExpense = (category: string, nominal: number, note: string) => {
    if (!activeShift) return;

    const newExpense: Expense = {
      id_pengeluaran: Date.now(),
      id_shift: activeShift.id_shift,
      kategori: category,
      nominal: nominal,
      keterangan: note,
      tanggal: new Date().toISOString()
    };

    const updatedExpenses = [...expenses, newExpense];
    setExpenses(updatedExpenses);
    setStorage('expenses', updatedExpenses);

    appendLog(`Catat pengeluaran operasional [${category}]: Rp ${nominal.toLocaleString('id-ID')} (${note})`);
  };

  // Render Login Screen if not authenticated
  if (!currentUser) {
    return <Login users={categories.length > 0 ? getStorage<UserType[]>('users', []) : []} onLogin={handleLogin} />;
  }

  const isAdmin = currentUser.id_role === 1;

  return (
    <div className="flex h-screen bg-slate-100 font-sans overflow-hidden">
      
      {/* 1. ZEN NAVIGATION RAIL (fixed 80px) on the left */}
      <div className="w-20 bg-[#1A1A1A] flex flex-col justify-between items-center py-4 border-r border-white/[0.04] shrink-0 z-10 select-none">
        
        {/* Top Logo / Japanese Stamp Accent */}
        <div className="flex flex-col items-center">
          <div className="w-10 h-10 rounded-lg bg-[#E63946] flex items-center justify-center text-white text-xs font-bold leading-none shadow-md font-serif mb-1">
            寿司
          </div>
          <span className="text-[8px] text-slate-500 font-mono tracking-widest font-bold uppercase leading-none mt-0.5">Moo</span>
        </div>

        {/* Mid Navigation Buttons */}
        <div className="flex flex-col gap-3.5 w-full px-1.5">
          {/* POS tab */}
          <button
            id="nav-pos"
            onClick={() => setActiveTab('pos')}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${activeTab === 'pos' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title="Cashier POS"
          >
            <ShoppingBag className="w-5 h-5 shrink-0" />
            <span>Kasir</span>
          </button>

          {/* Table Service Map */}
          <button
            id="nav-tables"
            onClick={() => setActiveTab('tables_map')}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${activeTab === 'tables_map' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title="Status Meja"
          >
            <MapPin className="w-5 h-5 shrink-0" />
            <span>Meja</span>
          </button>

          {/* Dashboard tab (Admin restricted visual gate) */}
          <button
            id="nav-dashboard"
            onClick={() => {
              if (!isAdmin) {
                alert('Akses Terbatas: Menu Dashboard Analisis hanya dapat dibuka oleh Owner/Admin.');
                return;
              }
              setActiveTab('dashboard');
            }}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${!isAdmin ? 'opacity-30 cursor-not-allowed' : ''} ${activeTab === 'dashboard' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title={isAdmin ? "Zen Dashboard" : "Khusus Admin"}
          >
            <LayoutDashboard className="w-5 h-5 shrink-0" />
            <span>Panel</span>
          </button>

          {/* Shift Sesi */}
          <button
            id="nav-shift"
            onClick={() => setActiveTab('shift')}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${activeTab === 'shift' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title="Kelola Shift & Pengeluaran"
          >
            <Clock className="w-5 h-5 shrink-0" />
            <span>Shift</span>
          </button>

          {/* Closing Sesi */}
          <button
            id="nav-closing"
            onClick={() => setActiveTab('closing')}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${activeTab === 'closing' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title="Audit Laci & Closing"
          >
            <Inbox className="w-5 h-5 shrink-0" />
            <span>Closing</span>
          </button>

          {/* Kelola Master (CRUD, Admin only) */}
          <button
            id="nav-master"
            onClick={() => {
              if (!isAdmin) {
                alert('Akses Terbatas: Pengelolaan menu porsi dan master data hanya dapat dibuka oleh Admin.');
                return;
              }
              setActiveTab('master');
            }}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${!isAdmin ? 'opacity-30 cursor-not-allowed' : ''} ${activeTab === 'master' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title={isAdmin ? "Kelola Master Menu" : "Khusus Admin"}
          >
            <Settings className="w-5 h-5 shrink-0" />
            <span>Master</span>
          </button>

          {/* Laporan & Void */}
          <button
            id="nav-reports"
            onClick={() => setActiveTab('reports')}
            className={`flex flex-col items-center py-2.5 rounded-lg transition-all gap-1 text-[9px] font-bold tracking-wide border ${activeTab === 'reports' ? 'bg-[#E63946] text-white border-[#E63946] shadow' : 'text-slate-400 border-transparent hover:text-white'}`}
            title="Laporan Invoice & Void"
          >
            <FileText className="w-5 h-5 shrink-0" />
            <span>Invoice</span>
          </button>
        </div>

        {/* Bottom User Avatar / Logout Trigger */}
        <div className="flex flex-col items-center gap-3 w-full border-t border-white/[0.04] pt-4 px-1">
          <div className="flex flex-col items-center gap-0.5" title={`${currentUser.nama} (${isAdmin ? 'Admin' : 'Kasir'})`}>
            <div className="w-8 h-8 rounded-full bg-slate-800 border border-white/[0.1] flex items-center justify-center text-[#E63946]">
              <User className="w-4 h-4" />
            </div>
            <span className="text-[7px] text-slate-500 font-mono truncate max-w-[64px] text-center">{currentUser.nama.split(' ')[0]}</span>
          </div>

          <button
            id="nav-logout"
            onClick={handleLogout}
            className="p-2 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-slate-900 transition-colors"
            title="Keluar dari Akun"
          >
            <LogOut className="w-4.5 h-4.5" />
          </button>
        </div>
      </div>

      {/* 2. MAIN SUB-PAGE VIEW CONTAINER */}
      <div className="flex-1 flex flex-col min-w-0">
        
        {/* Top Header Navigation Strip */}
        <header className="bg-white border-b border-slate-200/80 px-6 py-4 flex items-center justify-between select-none shrink-0">
          <div className="flex items-center gap-3">
            <h1 className="text-sm font-black text-slate-950 uppercase tracking-wider font-mono">
              SUSHIMOO <span className="text-[#E63946]">POS</span>
            </h1>
            <span className="text-[9px] font-mono text-slate-400 bg-slate-100 px-2 py-0.5 rounded-full uppercase font-bold">
              {currentUser.id_role === 1 ? 'Owner / Administrator' : 'Kasir Stan'}
            </span>
          </div>

          <div className="flex items-center gap-4 text-xs font-mono">
            {/* Cash shift balance banner indicator */}
            <div className="flex items-center gap-1.5 text-[10px] text-slate-600 bg-slate-100 border border-slate-200 px-3 py-1 rounded">
              <span className={`w-2 h-2 rounded-full ${activeShift ? 'bg-emerald-500' : 'bg-slate-400'}`} />
              <span className="font-bold">SHIFT:</span>
              <span className="font-medium text-slate-800">{activeShift ? `AKTIF (ID: #${activeShift.id_shift})` : 'TUTUP'}</span>
            </div>

            <div className="hidden sm:block text-[10px] text-slate-500 font-bold">
              Hari Audit: {new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
            </div>
          </div>
        </header>

        {/* Content View Canvas Area */}
        <main className="flex-1 overflow-y-auto p-6 relative">
          
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 5 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -5 }}
              transition={{ duration: 0.15 }}
              className="h-full"
            >
              
              {/* POS screen */}
              {activeTab === 'pos' && (
                <PosView
                  categories={categories}
                  products={products}
                  tables={tables}
                  paymentMethods={paymentMethods}
                  activeShift={activeShift}
                  onUpdateProducts={updateProducts}
                  onUpdateTables={updateTables}
                  onCreateTransaction={handleCreateTransaction}
                  currentUser={currentUser}
                />
              )}

              {/* Table Status Map view */}
              {activeTab === 'tables_map' && (
                <div className="bg-white border border-slate-200 p-6 rounded-xl shadow-sm space-y-6">
                  <div>
                    <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
                      <MapPin className="w-5 h-5 text-[#E63946]" /> Tata Letak Meja Restoran
                    </h2>
                    <p className="text-slate-500 text-xs">Peta meja dine-in Sushimoo beserta indikator ketersediaan kursi.</p>
                  </div>

                  <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-6">
                    {tables.map(t => {
                      const isOccupied = t.status === 'occupied';
                      
                      return (
                        <div
                          key={t.id_meja}
                          className={`p-6 border rounded-xl shadow-sm text-center flex flex-col justify-between h-40 transition-all ${isOccupied ? 'border-amber-200 bg-amber-50/20' : 'border-slate-200 bg-white hover:border-slate-300'}`}
                        >
                          <div className="space-y-1">
                            <span className="font-mono font-bold text-slate-950 text-lg bg-slate-100 px-3 py-1 rounded">
                              {t.nomor_meja}
                            </span>
                            <p className="text-[10px] text-slate-500 font-mono mt-2">{t.kapasitas} Kursi Tamu</p>
                          </div>

                          <div className="flex items-center justify-center gap-1.5 mt-3">
                            <span className={`w-2 h-2 rounded-full ${isOccupied ? 'bg-amber-500' : 'bg-emerald-500'}`} />
                            <span className="text-[10px] uppercase font-mono tracking-wider font-extrabold text-slate-700">
                              {isOccupied ? 'Terisi (Occupied)' : 'Kosong (Ready)'}
                            </span>
                          </div>
                        </div>
                      );
                    })}
                  </div>

                  <div className="border-t border-slate-100 pt-4 flex gap-6 text-[10px] text-slate-500 font-mono">
                    <div className="flex items-center gap-1.5">
                      <span className="w-2.5 h-2.5 rounded-full bg-emerald-500" />
                      <span>Hijau = Tersedia untuk Tamu Baru</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <span className="w-2.5 h-2.5 rounded-full bg-amber-500" />
                      <span>Amber = Sedang Menyantap Sushi</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Dashboard screen (Admin only) */}
              {activeTab === 'dashboard' && (
                <DashboardView
                  transactions={transactions}
                  products={products}
                  expenses={expenses}
                  logs={logs}
                />
              )}

              {/* Shift and Expenses screen */}
              {activeTab === 'shift' && (
                <ShiftView
                  shifts={shifts}
                  expenses={expenses}
                  activeShift={activeShift}
                  onOpenShift={handleOpenShift}
                  onAddExpense={handleAddExpense}
                  currentUser={currentUser}
                />
              )}

              {/* Closing Sesi screen */}
              {activeTab === 'closing' && (
                <ClosingView
                  activeShift={activeShift}
                  transactions={transactions}
                  expenses={expenses}
                  onCloseShift={handleCloseShift}
                  currentUser={currentUser}
                />
              )}

              {/* Kelola Master menu screen (Admin only) */}
              {activeTab === 'master' && (
                <ManagementView
                  categories={categories}
                  products={products}
                  tables={tables}
                  onUpdateCategories={updateCategories}
                  onUpdateProducts={updateProducts}
                  onUpdateTables={updateTables}
                />
              )}

              {/* Invoice Reports & Void list screen */}
              {activeTab === 'reports' && (
                <ReportView
                  transactions={transactions}
                  paymentMethods={paymentMethods}
                  onVoidTransaction={handleVoidTransaction}
                  currentUser={currentUser}
                />
)}

             </motion.div>
          </AnimatePresence>

        </main>
      </div>

    </div>
  );
}
