import React, { useState } from 'react';
import { 
  FileText, 
  Printer, 
  Trash2, 
  X, 
  Check, 
  Search, 
  Calendar, 
  TrendingUp,
  AlertOctagon,
  Eye,
  RotateCcw
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Transaction, PaymentMethod } from '../types';

interface ReportViewProps {
  transactions: Transaction[];
  paymentMethods: PaymentMethod[];
  onVoidTransaction: (id: number, reason: string) => void;
  currentUser: { nama: string; id_role: number };
}

export default function ReportView({ 
  transactions, 
  paymentMethods, 
  onVoidTransaction,
  currentUser
}: ReportViewProps) {
  
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'paid' | 'cancelled'>('all');
  
  // Modal view states
  const [selectedTx, setSelectedTx] = useState<Transaction | null>(null);
  const [voidingTxId, setVoidingTxId] = useState<number | null>(null);
  const [voidReason, setVoidReason] = useState('');

  const filteredTx = transactions.filter(tx => {
    const matchSearch = tx.invoice_number.toLowerCase().includes(searchQuery.toLowerCase());
    const matchStatus = statusFilter === 'all' || tx.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const handleVoidSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (voidingTxId === null || !voidReason.trim()) return;

    onVoidTransaction(voidingTxId, voidReason.trim());
    setVoidingTxId(null);
    setVoidReason('');
    setSelectedTx(null); // Close view details if open
    alert('Transaksi berhasil di-void (dibatalkan)! Stok porsi dikembalikan.');
  };

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
  };

  const isAdmin = currentUser.id_role === 1;

  return (
    <div id="report-view-layout" className="space-y-6">
      
      {/* Search and Filters bar */}
      <div className="bg-white border border-slate-200 p-4 rounded-xl shadow-sm flex flex-col sm:flex-row items-center justify-between gap-4">
        {/* Search Input */}
        <div className="relative w-full sm:max-w-xs text-xs">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            id="tx-search"
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Cari No. Invoice..."
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded text-slate-800 placeholder-slate-400 focus:outline-none focus:border-[#E63946]"
          />
        </div>

        {/* Status Filters */}
        <div className="flex bg-slate-100 p-1 rounded-lg text-xs font-bold shrink-0">
          <button
            id="filter-status-all"
            onClick={() => setStatusFilter('all')}
            className={`px-3.5 py-1.5 rounded-md transition-all ${statusFilter === 'all' ? 'bg-[#1A1A1A] text-white' : 'text-slate-600 hover:text-slate-900'}`}
          >
            Semua
          </button>
          <button
            id="filter-status-paid"
            onClick={() => setStatusFilter('paid')}
            className={`px-3.5 py-1.5 rounded-md transition-all ${statusFilter === 'paid' ? 'bg-[#1A1A1A] text-white' : 'text-slate-600 hover:text-slate-900'}`}
          >
            Sukses (Paid)
          </button>
          <button
            id="filter-status-cancelled"
            onClick={() => setStatusFilter('cancelled')}
            className={`px-3.5 py-1.5 rounded-md transition-all ${statusFilter === 'cancelled' ? 'bg-[#1A1A1A] text-white' : 'text-slate-600 hover:text-slate-900'}`}
          >
            Void (Cancelled)
          </button>
        </div>
      </div>

      {/* Transactions list table */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden text-xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse" id="table-transactions">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
                <th className="p-4">No Invoice</th>
                <th className="p-4">Tanggal</th>
                <th className="p-4">Total Belanja</th>
                <th className="p-4">Metode Bayar</th>
                <th className="p-4">Status</th>
                <th className="p-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
              {filteredTx.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center text-slate-400 font-mono text-xs">
                    Tidak ada log invoice transaksi ditemukan.
                  </td>
                </tr>
              ) : (
                filteredTx.slice().reverse().map(tx => (
                  <tr key={tx.id_transaksi} className="hover:bg-slate-50/50">
                    <td className="p-4 font-bold text-slate-950 font-mono">{tx.invoice_number}</td>
                    <td className="p-4 text-slate-500">
                      {new Date(tx.tanggal).toLocaleString('id-ID', { dateStyle: 'short', timeStyle: 'short' })}
                    </td>
                    <td className="p-4 font-mono font-bold text-slate-900">{formatIDR(tx.total)}</td>
                    <td className="p-4">
                      {paymentMethods.find(m => m.id_metode === tx.id_metode)?.nama_metode || '-'}
                    </td>
                    <td className="p-4">
                      <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${tx.status === 'paid' ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-500'}`}>
                        {tx.status === 'paid' ? 'Paid' : 'Void'}
                      </span>
                    </td>
                    <td className="p-4 text-right flex items-center justify-end gap-2">
                      <button
                        onClick={() => setSelectedTx(tx)}
                        className="p-1 text-slate-400 hover:text-slate-600 flex items-center gap-1"
                        title="Lihat Detail"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      
                      {tx.status === 'paid' && (
                        <button
                          disabled={!isAdmin}
                          onClick={() => setVoidingTxId(tx.id_transaksi)}
                          className="p-1 text-slate-400 hover:text-rose-600 disabled:opacity-30 disabled:cursor-not-allowed"
                          title={isAdmin ? "Void Transaksi" : "Butuh Otorisasi Admin"}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* DETAIL VIEW MODAL */}
      <AnimatePresence>
        {selectedTx && (
          <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="bg-white rounded-xl shadow-2xl p-6 max-w-sm w-full relative border border-slate-100 flex flex-col max-h-[90vh] text-xs"
            >
              <button
                onClick={() => setSelectedTx(null)}
                className="absolute top-4 right-4 p-1 rounded-full text-slate-400 hover:bg-slate-100"
              >
                <X className="w-5 h-5" />
              </button>

              <div className="flex-1 overflow-y-auto pr-1">
                <div className="text-center mb-4 border-b border-dashed border-slate-300 pb-4">
                  <p className="text-lg font-bold tracking-widest font-serif">SUSHIMOO</p>
                  <p className="text-[10px] text-slate-500 uppercase tracking-widest font-mono">Invoice Rincian</p>
                </div>

                <div className="font-mono text-[10px] text-slate-600 space-y-1 border-b border-dashed border-slate-300 pb-3 mb-3">
                  <div className="flex justify-between">
                    <span>No Invoice:</span>
                    <span className="font-bold text-slate-950">{selectedTx.invoice_number}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Status:</span>
                    <span className={`font-bold ${selectedTx.status === 'paid' ? 'text-emerald-600' : 'text-rose-600'}`}>
                      {selectedTx.status === 'paid' ? 'Paid (Sukses)' : 'Void (Dibatalkan)'}
                    </span>
                  </div>
                  {selectedTx.void_reason && (
                    <div className="flex justify-between text-rose-600">
                      <span>Alasan Void:</span>
                      <span className="font-bold">{selectedTx.void_reason}</span>
                    </div>
                  )}
                  <div className="flex justify-between">
                    <span>Waktu:</span>
                    <span>{new Date(selectedTx.tanggal).toLocaleString('id-ID')}</span>
                  </div>
                </div>

                {/* Items detail list */}
                <div className="space-y-2 border-b border-dashed border-slate-300 pb-3 mb-3 font-mono text-[10px]">
                  {selectedTx.details.map(item => (
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
                <div className="font-mono text-[10px] text-slate-600 space-y-1 pb-3">
                  <div className="flex justify-between font-bold text-slate-950 text-xs border-t border-dotted border-slate-200 pt-1 mt-1">
                    <span>TOTAL</span>
                    <span>{formatIDR(selectedTx.total)}</span>
                  </div>
                  <div className="flex justify-between mt-2">
                    <span>Cara Bayar:</span>
                    <span>{paymentMethods.find(m => m.id_metode === selectedTx.id_metode)?.nama_metode}</span>
                  </div>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-slate-100 flex gap-2">
                <button
                  onClick={() => setSelectedTx(null)}
                  className="flex-1 py-2 bg-slate-900 hover:bg-slate-800 text-white font-bold text-xs uppercase tracking-widest rounded transition-colors"
                >
                  Tutup Detail
                </button>
                <button
                  onClick={() => {
                    alert('Simulasi: Mencetak ulang struk thermal POS...');
                  }}
                  className="p-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded border border-slate-200"
                  title="Print Copy"
                >
                  <Printer className="w-4.5 h-4.5" />
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* VOID INPUT REASON MODAL */}
      <AnimatePresence>
        {voidingTxId !== null && (
          <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="bg-white rounded-xl shadow-2xl p-6 max-w-sm w-full relative border border-slate-100 text-xs"
            >
              <button
                onClick={() => setVoidingTxId(null)}
                className="absolute top-4 right-4 p-1 rounded-full text-slate-400 hover:bg-slate-100"
              >
                <X className="w-5 h-5" />
              </button>

              <div className="text-center mb-4">
                <AlertOctagon className="w-10 h-10 text-rose-600 mx-auto mb-2" />
                <h3 className="text-sm font-bold text-slate-900">Otorisasi Void Transaksi</h3>
                <p className="text-slate-500 text-[10px] mt-1">Pembatalan struk memerlukan alasan audit pencatatan keuangan resmi.</p>
              </div>

              <form onSubmit={handleVoidSubmit} className="space-y-3">
                <div>
                  <label className="block text-[10px] uppercase tracking-wider text-slate-500 font-bold mb-1">
                    Alasan Pembatalan (Void Reason)
                  </label>
                  <input
                    id="void-reason"
                    type="text"
                    required
                    value={voidReason}
                    onChange={e => setVoidReason(e.target.value)}
                    placeholder="Salah input meja / order didobel / dibatalkan tamu"
                    className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded text-slate-900 focus:outline-none focus:border-[#E63946]"
                  />
                </div>

                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setVoidingTxId(null)}
                    className="flex-1 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-[10px] uppercase tracking-wider rounded border border-slate-200"
                  >
                    Batal
                  </button>
                  <button
                    id="void-submit"
                    type="submit"
                    className="flex-1 py-2 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-bold text-[10px] uppercase tracking-wider rounded shadow transition-colors"
                  >
                    Konfirmasi Void
                  </button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
}
