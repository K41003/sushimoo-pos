import React, { useState, useMemo } from 'react';
import { 
  Key, 
  PlusCircle, 
  TrendingDown, 
  Calendar, 
  User, 
  Coins, 
  FileText,
  AlertCircle,
  Clock,
  Sparkles,
  Inbox
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Shift, Expense } from '../types';

interface ShiftViewProps {
  shifts: Shift[];
  expenses: Expense[];
  activeShift: Shift | null;
  onOpenShift: (startingCash: number) => void;
  onAddExpense: (category: string, nominal: number, note: string) => void;
  currentUser: { nama: string; id_user: number };
}

export default function ShiftView({ 
  shifts, 
  expenses, 
  activeShift, 
  onOpenShift, 
  onAddExpense, 
  currentUser 
}: ShiftViewProps) {

  const [startingCash, setStartingCash] = useState<string>('200000'); // default modal
  const [expenseCategory, setExpenseCategory] = useState<string>('Bahan Baku');
  const [expenseNominal, setExpenseNominal] = useState<string>('');
  const [expenseNote, setExpenseNote] = useState<string>('');
  
  const handleOpenShift = (e: React.FormEvent) => {
    e.preventDefault();
    const cash = parseFloat(startingCash);
    if (isNaN(cash) || cash < 0) {
      alert('Masukkan nominal uang modal awal yang valid.');
      return;
    }
    onOpenShift(cash);
  };

  const handleAddExpense = (e: React.FormEvent) => {
    e.preventDefault();
    const nominal = parseFloat(expenseNominal);
    if (isNaN(nominal) || nominal <= 0) {
      alert('Masukkan nominal pengeluaran yang valid.');
      return;
    }
    if (!expenseNote.trim()) {
      alert('Tulis keterangan singkat mengenai pengeluaran.');
      return;
    }

    onAddExpense(expenseCategory, nominal, expenseNote.trim());
    setExpenseNominal('');
    setExpenseNote('');
    alert('Pengeluaran berhasil dicatat!');
  };

  // Sum active shift expenses
  const activeShiftExpenses = useMemo(() => {
    if (!activeShift) return [];
    return expenses.filter(e => e.id_shift === activeShift.id_shift);
  }, [expenses, activeShift]);

  const totalActiveExpensesSum = useMemo(() => {
    return activeShiftExpenses.reduce((sum, e) => sum + e.nominal, 0);
  }, [activeShiftExpenses]);

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
  };

  return (
    <div id="shift-layout" className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-stretch">
      
      {/* SHIFT STATUS & CONTROL PANEL (5 cols) */}
      <div className="lg:col-span-5 space-y-6">
        <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-5">
          <h3 className="font-bold text-slate-900 text-sm mb-4 flex items-center gap-2">
            <Clock className="w-4.5 h-4.5 text-[#E63946]" /> 
            Status Sesi Shift Kasir
          </h3>

          <AnimatePresence mode="wait">
            {activeShift ? (
              /* Shift is OPEN */
              <motion.div
                key="shift-open"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="space-y-4"
              >
                <div className="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-xs space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                    <span className="font-bold uppercase tracking-wider text-[10px]">Shift Aktif Berjalan</span>
                  </div>
                  <p>Sesi shift kasir sedang terbuka. Anda dapat melayani pesanan pelanggan dan mengelola cash drawer.</p>
                </div>

                <div className="border-t border-slate-100 pt-3 text-xs space-y-2.5 font-medium text-slate-600">
                  <div className="flex justify-between">
                    <span>Penanggung Jawab:</span>
                    <span className="text-slate-900 font-bold">{currentUser.nama}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Waktu Dibuka:</span>
                    <span className="text-slate-900 font-mono">{new Date(activeShift.open_time).toLocaleString('id-ID')}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Modal Awal (Petty Cash):</span>
                    <span className="text-slate-900 font-mono font-bold">{formatIDR(activeShift.petty_cash)}</span>
                  </div>
                  <div className="flex justify-between border-t border-dotted border-slate-200 pt-2 text-rose-700">
                    <span>Pengeluaran Sesi Ini:</span>
                    <span className="font-mono font-bold">({formatIDR(totalActiveExpensesSum)})</span>
                  </div>
                </div>
              </motion.div>
            ) : (
              /* Shift is CLOSED */
              <motion.div
                key="shift-closed"
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="space-y-4"
              >
                <div className="p-4 bg-amber-50 border border-amber-200 text-amber-800 rounded-lg text-xs flex gap-2">
                  <AlertCircle className="w-5 h-5 text-amber-600 shrink-0" />
                  <div>
                    <p className="font-bold uppercase tracking-wider text-[10px] mb-0.5">Shift Sedang Tertutup</p>
                    <p>Wajib membuka shift kasir baru dengan menginput nominal modal cash drawer agar sistem kasir dapat berjalan.</p>
                  </div>
                </div>

                <form onSubmit={handleOpenShift} className="space-y-3">
                  <div>
                    <label className="block text-[11px] uppercase tracking-wider text-slate-500 font-bold mb-1">
                      Modal Awal Cash Drawer (IDR)
                    </label>
                    <div className="relative">
                      <span className="absolute left-3 top-1/2 -translate-y-1/2 font-mono text-slate-400 text-xs font-bold">Rp</span>
                      <input
                        id="shift-starting-cash"
                        type="number"
                        required
                        value={startingCash}
                        onChange={e => setStartingCash(e.target.value)}
                        placeholder="200000"
                        className="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded focus:border-[#E63946] focus:outline-none text-slate-900 font-mono text-xs"
                      />
                    </div>
                  </div>

                  <button
                    id="shift-btn-open"
                    type="submit"
                    className="w-full py-2.5 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-xs uppercase tracking-widest rounded transition-colors"
                  >
                    Buka Shift Kasir Baru
                  </button>
                </form>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* LOG EXPENSES PANEL (Only shows when shift is active) */}
        <AnimatePresence>
          {activeShift && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="bg-white border border-slate-200 rounded-xl shadow-sm p-5 overflow-hidden"
            >
              <h3 className="font-bold text-slate-900 text-sm mb-4 flex items-center gap-2">
                <TrendingDown className="w-4.5 h-4.5 text-rose-600" />
                Catat Pengeluaran Sesi Shift
              </h3>

              <form onSubmit={handleAddExpense} className="space-y-3 text-xs">
                <div>
                  <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Kategori Pengeluaran</label>
                  <select
                    id="expense-category"
                    value={expenseCategory}
                    onChange={e => setExpenseCategory(e.target.value)}
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-700"
                  >
                    <option value="Bahan Baku">Pembelian Bahan Baku (Sashimi, etc.)</option>
                    <option value="Perlengkapan">Bahan Habis Pakai / Plastik / Thermal Roll</option>
                    <option value="Operasional">Kebersihan / Keamanan / Gas LPG</option>
                    <option value="Lain-lain">Lain-lain</option>
                  </select>
                </div>

                <div>
                  <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Nominal (Rp)</label>
                  <input
                    id="expense-nominal"
                    type="number"
                    required
                    value={expenseNominal}
                    onChange={e => setExpenseNominal(e.target.value)}
                    placeholder="Contoh: 45000"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded focus:outline-none focus:border-[#E63946] font-mono text-xs"
                  />
                </div>

                <div>
                  <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">Keterangan Singkat</label>
                  <input
                    id="expense-note"
                    type="text"
                    required
                    value={expenseNote}
                    onChange={e => setExpenseNote(e.target.value)}
                    placeholder="Beli es batu kristal / isi ulang gas sushi torch"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded focus:outline-none focus:border-[#E63946]"
                  />
                </div>

                <button
                  id="expense-btn-submit"
                  type="submit"
                  className="w-full py-2 bg-slate-900 hover:bg-slate-800 text-white font-bold text-[11px] uppercase tracking-wider rounded transition-colors"
                >
                  Catat Pengeluaran
                </button>
              </form>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* EXPENSES LOGS & HISTORY LIST (7 cols) */}
      <div className="lg:col-span-7 flex flex-col space-y-6">
        
        {/* Active shift expenses list */}
        {activeShift && (
          <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-5">
            <h3 className="font-bold text-slate-900 text-sm mb-1 flex items-center gap-2">
              <PlusCircle className="w-4.5 h-4.5 text-[#E63946]" /> 
              Daftar Pengeluaran Shift Ini
            </h3>
            <p className="text-[11px] text-slate-500 mb-4">Pengeluaran terikat ke shift aktif yang dibuka saat ini.</p>

            {activeShiftExpenses.length === 0 ? (
              <div className="p-12 text-center text-slate-400 font-mono text-xs border border-dashed border-slate-200 rounded-lg">
                Belum ada pengeluaran dicatat pada shift ini.
              </div>
            ) : (
              <div className="space-y-2 max-h-[220px] overflow-y-auto text-xs pr-1">
                {activeShiftExpenses.map(e => (
                  <div key={e.id_pengeluaran} className="flex items-center justify-between p-2.5 bg-rose-50/20 border border-rose-100 rounded">
                    <div>
                      <p className="font-bold text-slate-800">{e.keterangan}</p>
                      <p className="text-[9px] text-slate-400 font-mono uppercase tracking-wider">{e.kategori}</p>
                    </div>
                    <p className="font-bold text-rose-600 font-mono">({formatIDR(e.nominal)})</p>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Previous Shifts list */}
        <div className="bg-white border border-slate-200 rounded-xl shadow-sm p-5 flex-1 flex flex-col">
          <h3 className="font-bold text-slate-900 text-sm mb-1 flex items-center gap-2">
            <Inbox className="w-4.5 h-4.5 text-slate-700" />
            Riwayat Sesi Shift Sebelumnya
          </h3>
          <p className="text-[11px] text-slate-500 mb-4">Catatan komparasi shift yang telah ditutup.</p>

          <div className="flex-1 overflow-y-auto max-h-[350px] space-y-3 text-xs pr-1">
            {shifts.length === 0 ? (
              <div className="p-12 text-center text-slate-400 font-mono text-xs border border-dashed border-slate-200 rounded-lg">
                Belum ada riwayat shift tersimpan.
              </div>
            ) : (
              shifts.slice().reverse().map(s => (
                <div key={s.id_shift} className="p-3 bg-slate-50 border border-slate-200 rounded-lg flex justify-between items-center">
                  <div>
                    <div className="flex items-center gap-1.5 mb-1">
                      <span className="font-mono text-[10px] font-bold text-slate-800 bg-slate-200 px-1.5 py-0.5 rounded">
                        ID: #{s.id_shift}
                      </span>
                      <span className={`text-[9px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded ${s.status === 'open' ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-200 text-slate-700'}`}>
                        {s.status === 'open' ? 'Berjalan' : 'Tutup'}
                      </span>
                    </div>
                    <p className="text-[10px] text-slate-500 font-mono">
                      Buka: {new Date(s.open_time).toLocaleString('id-ID')}
                    </p>
                    {s.close_time && (
                      <p className="text-[10px] text-slate-500 font-mono">
                        Tutup: {new Date(s.close_time).toLocaleString('id-ID')}
                      </p>
                    )}
                  </div>

                  <div className="text-right font-mono text-[11px]">
                    <p className="text-slate-500">Modal: <span className="font-bold text-slate-800">{formatIDR(s.petty_cash)}</span></p>
                    {s.actual_cash && (
                      <p className="text-emerald-700">Closing: <span className="font-bold">{formatIDR(s.actual_cash)}</span></p>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

      </div>
    </div>
  );
}
