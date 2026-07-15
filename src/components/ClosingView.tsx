import React, { useState, useMemo } from 'react';
import { 
  Lock, 
  Coins, 
  DollarSign, 
  QrCode, 
  CreditCard, 
  Check, 
  AlertTriangle,
  Printer,
  Sparkles,
  ClipboardCheck
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Shift, Transaction, Expense, Closing } from '../types';

interface ClosingViewProps {
  activeShift: Shift | null;
  transactions: Transaction[];
  expenses: Expense[];
  onCloseShift: (actualCash: number, closingData: Closing) => void;
  currentUser: { nama: string; id_user: number };
}

export default function ClosingView({ 
  activeShift, 
  transactions, 
  expenses, 
  onCloseShift, 
  currentUser 
}: ClosingViewProps) {

  const [actualCashInput, setActualCashInput] = useState<string>('');
  const [showClosingSummary, setShowClosingSummary] = useState<Closing | null>(null);

  // 1. Gather all transactions in current active shift
  const shiftTransactions = useMemo(() => {
    if (!activeShift) return [];
    return transactions.filter(t => t.id_shift === activeShift.id_shift && t.status === 'paid');
  }, [transactions, activeShift]);

  // 2. Sum sales by method
  const totalSalesSum = useMemo(() => {
    return shiftTransactions.reduce((sum, t) => sum + t.total, 0);
  }, [shiftTransactions]);

  const cashSalesSum = useMemo(() => {
    return shiftTransactions
      .filter(t => t.id_metode === 1)
      .reduce((sum, t) => sum + t.total, 0);
  }, [shiftTransactions]);

  const qrisSalesSum = useMemo(() => {
    return shiftTransactions
      .filter(t => t.id_metode === 2)
      .reduce((sum, t) => sum + t.total, 0);
  }, [shiftTransactions]);

  const debitSalesSum = useMemo(() => {
    return shiftTransactions
      .filter(t => t.id_metode === 3)
      .reduce((sum, t) => sum + t.total, 0);
  }, [shiftTransactions]);

  // 3. Sum expenses in current shift
  const shiftExpenses = useMemo(() => {
    if (!activeShift) return [];
    return expenses.filter(e => e.id_shift === activeShift.id_shift);
  }, [expenses, activeShift]);

  const totalExpensesSum = useMemo(() => {
    return shiftExpenses.reduce((sum, e) => sum + e.nominal, 0);
  }, [shiftExpenses]);

  // 4. Calculate expected cash in drawer
  // Expected cash = Starting cash (petty_cash) + Cash sales - Expenses
  const expectedCashInDrawer = useMemo(() => {
    if (!activeShift) return 0;
    return activeShift.petty_cash + cashSalesSum - totalExpensesSum;
  }, [activeShift, cashSalesSum, totalExpensesSum]);

  const handleClosingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!activeShift) return;

    const actualCash = parseFloat(actualCashInput);
    if (isNaN(actualCash) || actualCash < 0) {
      alert('Masukkan nominal uang fisik laci yang valid.');
      return;
    }

    const confirmClose = window.confirm('Apakah Anda yakin ingin menutup shift kasir saat ini? Tindakan ini tidak dapat dibatalkan.');
    if (!confirmClose) return;

    const closingData: Closing = {
      id_closing: Date.now(),
      id_shift: activeShift.id_shift,
      total_penjualan: totalSalesSum,
      total_cash: cashSalesSum,
      total_qris: qrisSalesSum,
      total_debit: debitSalesSum,
      total_pengeluaran: totalExpensesSum,
      saldo_akhir: expectedCashInDrawer,
      waktu_closing: new Date().toISOString(),
      status: 'success'
    };

    onCloseShift(actualCash, closingData);
    setShowClosingSummary(closingData);
  };

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
  };

  if (!activeShift) {
    return (
      <div id="closing-view-inactive" className="bg-white border border-slate-200 p-8 rounded-xl shadow-sm max-w-lg mx-auto text-center space-y-4">
        <Lock className="w-10 h-10 text-slate-400 mx-auto" />
        <h3 className="font-bold text-slate-900 text-sm">Tidak ada Sesi Shift Kasir yang Aktif</h3>
        <p className="text-slate-500 text-xs">Semua sesi shift saat ini tertutup. Silakan menuju ke menu <strong>Shift</strong> untuk membuka sesi shift baru sebelum melakukan closing laci kasir.</p>
      </div>
    );
  }

  return (
    <div id="closing-view-active" className="max-w-4xl mx-auto space-y-6">
      
      {/* Title block */}
      <div className="bg-white border border-slate-200/80 p-5 rounded-xl shadow-sm">
        <h2 className="text-base font-bold text-slate-900 tracking-tight flex items-center gap-2">
          <ClipboardCheck className="w-5 h-5 text-[#E63946]" /> 
          Closing Sesi Shift Kasir
        </h2>
        <p className="text-slate-500 text-xs">Kalkulasi penutupan transaksi harian dan rekonsiliasi laci fisik kasir.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-12 gap-6 items-stretch">
        
        {/* SUMMARY COL (7 cols) */}
        <div className="md:col-span-7 bg-white border border-slate-200 rounded-xl p-5 shadow-sm space-y-5">
          <h3 className="font-bold text-slate-900 text-xs uppercase tracking-wider text-slate-400 border-b border-slate-100 pb-2">
            Ringkasan Buku Kasir Sesi Ini
          </h3>

          <div className="grid grid-cols-3 gap-3">
            <div className="p-3 bg-slate-50 border border-slate-150 rounded text-center">
              <p className="text-[9px] text-slate-400 uppercase font-bold font-mono">Tunai (Cash)</p>
              <p className="font-bold text-slate-950 font-mono mt-0.5 text-xs">{formatIDR(cashSalesSum)}</p>
            </div>
            <div className="p-3 bg-slate-50 border border-slate-150 rounded text-center">
              <p className="text-[9px] text-slate-400 uppercase font-bold font-mono">Digital (QRIS)</p>
              <p className="font-bold text-[#E63946] font-mono mt-0.5 text-xs">{formatIDR(qrisSalesSum)}</p>
            </div>
            <div className="p-3 bg-slate-50 border border-slate-150 rounded text-center">
              <p className="text-[9px] text-slate-400 uppercase font-bold font-mono">Debit Card</p>
              <p className="font-bold text-slate-700 font-mono mt-0.5 text-xs">{formatIDR(debitSalesSum)}</p>
            </div>
          </div>

          <div className="space-y-2.5 font-medium text-xs text-slate-600">
            <div className="flex justify-between">
              <span>Total Omset Penjualan (A):</span>
              <span className="text-slate-950 font-bold font-mono">{formatIDR(totalSalesSum)}</span>
            </div>
            <div className="flex justify-between">
              <span>Modal Petty Cash (B):</span>
              <span className="text-slate-950 font-mono">{formatIDR(activeShift.petty_cash)}</span>
            </div>
            <div className="flex justify-between text-rose-600">
              <span>Pengeluaran Operasional (C):</span>
              <span className="font-mono font-bold">({formatIDR(totalExpensesSum)})</span>
            </div>
            
            <div className="flex justify-between border-t border-slate-200 pt-2 text-slate-900 font-bold text-sm">
              <span>Saldo Ekspektasi Tunai di Laci:</span>
              <span className="font-mono text-emerald-600">{formatIDR(expectedCashInDrawer)}</span>
            </div>
            <p className="text-[10px] text-slate-500 font-mono text-right italic">
              Rumus: Modal Awal (B) + Penjualan Tunai - Pengeluaran (C)
            </p>
          </div>

          {/* List of expenses for reference */}
          {shiftExpenses.length > 0 && (
            <div className="bg-slate-50 border border-slate-100 p-3 rounded-lg space-y-2">
              <p className="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Rincian Pengeluaran Shift:</p>
              <div className="space-y-1 max-h-[100px] overflow-y-auto text-[11px]">
                {shiftExpenses.map(e => (
                  <div key={e.id_pengeluaran} className="flex justify-between text-slate-600">
                    <span className="truncate max-w-[180px]">{e.keterangan}</span>
                    <span className="font-mono">{formatIDR(e.nominal)}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* INPUT RECONCILIATION COL (5 cols) */}
        <div className="md:col-span-5 bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex flex-col justify-between">
          <form onSubmit={handleClosingSubmit} className="space-y-4">
            <h3 className="font-bold text-slate-900 text-xs uppercase tracking-wider text-slate-400 border-b border-slate-100 pb-2">
              Rekonsiliasi Laci Kasir
            </h3>

            <div>
              <label className="block text-[11px] uppercase tracking-wider text-slate-500 font-bold mb-1">
                Total Uang Fisik di Laci (Rp)
              </label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 font-mono text-slate-400 text-xs font-bold">Rp</span>
                <input
                  id="closing-actual-cash"
                  type="number"
                  required
                  value={actualCashInput}
                  onChange={e => setActualCashInput(e.target.value)}
                  placeholder="Contoh: 150000"
                  className="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded focus:border-[#E63946] focus:outline-none text-slate-900 font-mono text-xs font-bold"
                />
              </div>
              <p className="text-[9px] text-slate-400 mt-1">
                Hitung uang fisik di drawer (kertas + koin) secara manual lalu masukkan nominalnya di atas.
              </p>
            </div>

            {actualCashInput && (
              <div className="p-3 bg-slate-50 border rounded text-xs space-y-1 font-mono">
                <div className="flex justify-between text-slate-500">
                  <span>Ekspektasi:</span>
                  <span>{formatIDR(expectedCashInDrawer)}</span>
                </div>
                <div className="flex justify-between text-slate-500">
                  <span>Uang Fisik:</span>
                  <span>{formatIDR(parseFloat(actualCashInput) || 0)}</span>
                </div>
                {(() => {
                  const actual = parseFloat(actualCashInput) || 0;
                  const diff = actual - expectedCashInDrawer;
                  return (
                    <div className="flex justify-between border-t border-slate-200 pt-1 mt-1 font-bold">
                      <span>Selisih:</span>
                      {diff === 0 ? (
                        <span className="text-emerald-600">PAS (0)</span>
                      ) : diff > 0 ? (
                        <span className="text-blue-600">SURPLUS (+{formatIDR(diff)})</span>
                      ) : (
                        <span className="text-rose-600">DEFISIT ({formatIDR(diff)})</span>
                      )}
                    </div>
                  );
                })()}
              </div>
            )}

            <button
              id="closing-btn-submit"
              type="submit"
              className="w-full py-2.5 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-xs uppercase tracking-widest rounded transition-colors flex items-center justify-center gap-1.5 shadow"
            >
              <Check className="w-4.5 h-4.5" /> Close Shift & Cetak Recap
            </button>
          </form>

          <p className="text-[9px] text-slate-400 text-center mt-4">
            Penutupan shift akan mencatat log transaksi secara permanen ke database riwayat audit.
          </p>
        </div>

      </div>

      {/* COMPLETED CLOSING DIALOG / RECEIPT */}
      <AnimatePresence>
        {showClosingSummary && (
          <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="bg-white rounded-xl shadow-2xl p-6 max-w-sm w-full relative border border-slate-100 flex flex-col max-h-[90vh]"
            >
              <div className="flex-1 overflow-y-auto pr-1 text-slate-800">
                <div className="text-center mb-4 border-b border-dashed border-slate-300 pb-4">
                  <p className="text-xl font-bold tracking-widest font-serif uppercase">SLIP CLOSING SHIFT</p>
                  <p className="text-[10px] text-slate-500 uppercase tracking-widest font-mono mt-0.5">SUSHIMOO RESTORAN</p>
                  <p className="text-[9px] text-slate-400 font-mono">Rekonsiliasi Keuangan Harian</p>
                </div>

                <div className="font-mono text-[10px] text-slate-600 space-y-1 border-b border-dashed border-slate-300 pb-3 mb-3">
                  <div className="flex justify-between">
                    <span>Shift ID:</span>
                    <span className="font-bold text-slate-950">#{activeShift.id_shift}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Waktu Closing:</span>
                    <span>{new Date(showClosingSummary.waktu_closing).toLocaleString('id-ID')}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Kasir Closing:</span>
                    <span>{currentUser.nama}</span>
                  </div>
                </div>

                <div className="font-mono text-[10px] text-slate-700 space-y-1.5 border-b border-dashed border-slate-300 pb-3 mb-3">
                  <p className="font-bold text-slate-950 uppercase tracking-wider text-[9px] mb-1">Rincian Penjualan (Omset)</p>
                  <div className="flex justify-between">
                    <span>Penjualan Tunai:</span>
                    <span>{formatIDR(showClosingSummary.total_cash)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Penjualan QRIS:</span>
                    <span>{formatIDR(showClosingSummary.total_qris)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Penjualan Debit:</span>
                    <span>{formatIDR(showClosingSummary.total_debit)}</span>
                  </div>
                  <div className="flex justify-between font-bold text-slate-950 border-t border-dotted border-slate-200 pt-1">
                    <span>TOTAL OMSET:</span>
                    <span>{formatIDR(showClosingSummary.total_penjualan)}</span>
                  </div>
                </div>

                <div className="font-mono text-[10px] text-slate-700 space-y-1.5 border-b border-dashed border-slate-300 pb-3 mb-3">
                  <p className="font-bold text-slate-950 uppercase tracking-wider text-[9px] mb-1">Audit Cash Drawer (Laci)</p>
                  <div className="flex justify-between">
                    <span>Modal Petty Cash:</span>
                    <span>{formatIDR(activeShift.petty_cash)}</span>
                  </div>
                  <div className="flex justify-between text-rose-600">
                    <span>Pengeluaran Shift:</span>
                    <span>({formatIDR(showClosingSummary.total_pengeluaran)})</span>
                  </div>
                  <div className="flex justify-between border-t border-dotted border-slate-200 pt-1 font-bold">
                    <span>Ekspektasi Uang:</span>
                    <span>{formatIDR(showClosingSummary.saldo_akhir)}</span>
                  </div>
                  <div className="flex justify-between font-bold text-slate-950">
                    <span>Uang Fisik Dihitung:</span>
                    <span>{formatIDR(parseFloat(actualCashInput) || 0)}</span>
                  </div>
                  {(() => {
                    const actual = parseFloat(actualCashInput) || 0;
                    const diff = actual - showClosingSummary.saldo_akhir;
                    return (
                      <div className="flex justify-between font-bold text-slate-950 pt-1 border-t border-dotted border-slate-200">
                        <span>SELISIH:</span>
                        {diff === 0 ? (
                          <span className="text-emerald-600">PAS (0)</span>
                        ) : diff > 0 ? (
                          <span className="text-blue-600">+{formatIDR(diff)} (Surplus)</span>
                        ) : (
                          <span className="text-rose-600">{formatIDR(diff)} (Defisit)</span>
                        )}
                      </div>
                    );
                  })()}
                </div>

                <div className="text-center font-mono text-[8px] text-slate-400 border-t border-dashed border-slate-200 pt-3">
                  <p>SLIP AUDIT RESMI RESTORAN JEPANG SUSHIMOO</p>
                  <p className="mt-0.5">Disimpan secara digital untuk rekap bulanan.</p>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-slate-100 flex gap-2">
                <button
                  id="closing-confirm-done"
                  onClick={() => setShowClosingSummary(null)}
                  className="flex-1 py-2.5 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-xs uppercase tracking-widest rounded flex items-center justify-center gap-1.5 shadow"
                >
                  <Check className="w-4 h-4" /> Selesai
                </button>
                <button
                  onClick={() => {
                    alert('Simulasi: Mencetak slip closing shift via Blue Thermal Printer...');
                  }}
                  className="p-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded border border-slate-200"
                  title="Print slip"
                >
                  <Printer className="w-4 h-4" />
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
}
