import React from 'react';
import { 
  TrendingUp, 
  DollarSign, 
  ShoppingBag, 
  Users, 
  Clock, 
  ArrowUpRight,
  Sparkles,
  ClipboardList
} from 'lucide-react';
import { 
  ResponsiveContainer, 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  Tooltip, 
  PieChart, 
  Pie, 
  Cell, 
  Legend, 
  BarChart, 
  Bar 
} from 'recharts';
import { Transaction, Product, Expense, ActivityLog } from '../types';

interface DashboardViewProps {
  transactions: Transaction[];
  products: Product[];
  expenses: Expense[];
  logs: ActivityLog[];
}

export default function DashboardView({ transactions, products, expenses, logs }: DashboardViewProps) {
  // 1. Calculate general stats
  const paidTransactions = transactions.filter(t => t.status === 'paid');
  const totalRevenue = paidTransactions.reduce((sum, t) => sum + t.total, 0);
  const totalTransactions = transactions.length;
  const voidedTransactionsCount = transactions.filter(t => t.status === 'cancelled').length;
  
  const totalExpenses = expenses.reduce((sum, e) => sum + e.nominal, 0);
  const netIncome = totalRevenue - totalExpenses;
  
  const totalItemsSold = paidTransactions.reduce((sum, t) => {
    return sum + t.details.reduce((subSum, item) => subSum + item.qty, 0);
  }, 0);

  const avgOrderValue = paidTransactions.length > 0 ? totalRevenue / paidTransactions.length : 0;

  // 2. Generate sales chart data (last 7 days or custom)
  // Let's create an array of last 7 days ending at current date
  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    return d.toISOString().split('T')[0];
  });

  const salesData = last7Days.map(dateStr => {
    const dayTransactions = paidTransactions.filter(t => t.tanggal.startsWith(dateStr));
    const daySales = dayTransactions.reduce((sum, t) => sum + t.total, 0);
    const dayExpensesSum = expenses.filter(e => e.tanggal.startsWith(dateStr)).reduce((sum, e) => sum + e.nominal, 0);
    
    // Format date for display
    const dateObj = new Date(dateStr);
    const label = dateObj.toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric' });
    
    return {
      name: label,
      sales: daySales,
      expenses: dayExpensesSum,
      net: daySales - dayExpensesSum
    };
  });

  // 3. Payment Methods stats
  const paymentMethodsCounts: Record<string, number> = { 'Cash': 0, 'QRIS': 0, 'Debit': 0 };
  paidTransactions.forEach(t => {
    if (t.id_metode === 1) paymentMethodsCounts['Cash'] += t.total;
    else if (t.id_metode === 2) paymentMethodsCounts['QRIS'] += t.total;
    else if (t.id_metode === 3) paymentMethodsCounts['Debit'] += t.total;
  });

  const pieData = Object.entries(paymentMethodsCounts).map(([name, value]) => ({
    name,
    value
  })).filter(item => item.value > 0);

  const COLORS = ['#1A1A1A', '#E63946', '#475569'];

  // 4. Top Selling Products
  const productSalesMap: Record<number, { name: string; qty: number; revenue: number }> = {};
  paidTransactions.forEach(t => {
    t.details.forEach(detail => {
      if (!productSalesMap[detail.id_produk]) {
        productSalesMap[detail.id_produk] = {
          name: detail.nama_produk,
          qty: 0,
          revenue: 0
        };
      }
      productSalesMap[detail.id_produk].qty += detail.qty;
      productSalesMap[detail.id_produk].revenue += detail.subtotal;
    });
  });

  const topProducts = Object.values(productSalesMap)
    .sort((a, b) => b.qty - a.qty)
    .slice(0, 5);

  const formatIDR = (num: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num);
  };

  return (
    <div id="dashboard-view" className="space-y-6">
      {/* Welcome Banner */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white border border-slate-200/80 p-6 rounded-xl shadow-sm">
        <div>
          <h2 className="text-xl font-bold text-slate-900 tracking-tight flex items-center gap-2">
            Ringkasan Zen Dashboard <Sparkles className="w-5 h-5 text-[#E63946]" />
          </h2>
          <p className="text-slate-500 text-xs">Pantau performa penjualan, pengeluaran, dan log aktivitas restoran secara berkala.</p>
        </div>
        <div className="flex items-center gap-2 text-xs font-mono bg-[#1A1A1A] text-white px-3 py-1.5 rounded">
          <Clock className="w-4 h-4 text-[#E63946]" />
          Sesi Admin: Aktif
        </div>
      </div>

      {/* Grid Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Card 1: Total Pendapatan */}
        <div id="stat-revenue" className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">Pendapatan Kotor</p>
            <p className="text-2xl font-bold text-slate-950">{formatIDR(totalRevenue)}</p>
            <p className="text-[10px] text-slate-500">Dari {paidTransactions.length} transaksi sukses</p>
          </div>
          <div className="p-3 bg-red-50 text-[#E63946] rounded-lg">
            <DollarSign className="w-6 h-6" />
          </div>
        </div>

        {/* Card 2: Pengeluaran */}
        <div id="stat-expenses" className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">Total Pengeluaran</p>
            <p className="text-2xl font-bold text-slate-950">{formatIDR(totalExpenses)}</p>
            <p className="text-[10px] text-slate-500">Untuk biaya operasional & shift</p>
          </div>
          <div className="p-3 bg-slate-100 text-slate-700 rounded-lg">
            <ClipboardList className="w-6 h-6" />
          </div>
        </div>

        {/* Card 3: Pendapatan Bersih */}
        <div id="stat-net-income" className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">Pendapatan Bersih</p>
            <p className={`text-2xl font-bold ${netIncome >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
              {formatIDR(netIncome)}
            </p>
            <p className="text-[10px] text-slate-500">Omset kotor dikurangi biaya</p>
          </div>
          <div className="p-3 bg-emerald-50 text-emerald-600 rounded-lg">
            <TrendingUp className="w-6 h-6" />
          </div>
        </div>

        {/* Card 4: Items Terjual */}
        <div id="stat-items-sold" className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex items-center justify-between">
          <div className="space-y-1">
            <p className="text-[11px] font-bold text-slate-500 uppercase tracking-wider">Porsi Terjual</p>
            <p className="text-2xl font-bold text-slate-950">{totalItemsSold}</p>
            <p className="text-[10px] text-slate-500">Rata-rata {formatIDR(avgOrderValue)} / order</p>
          </div>
          <div className="p-3 bg-slate-900 text-white rounded-lg">
            <ShoppingBag className="w-6 h-6" />
          </div>
        </div>
      </div>

      {/* Charts section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Trend Area Chart */}
        <div className="lg:col-span-2 bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex flex-col h-[350px]">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h3 className="text-sm font-bold text-slate-900">Tren Keuangan (7 Hari Terakhir)</h3>
              <p className="text-[11px] text-slate-500">Grafik omset harian vs biaya pengeluaran harian</p>
            </div>
            <span className="text-[10px] font-mono bg-slate-100 px-2 py-1 rounded">Harian</span>
          </div>
          <div className="flex-1 w-full text-xs">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={salesData} margin={{ top: 5, right: 5, left: 0, bottom: 5 }}>
                <defs>
                  <linearGradient id="colorSales" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#E63946" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#E63946" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <XAxis dataKey="name" stroke="#64748b" fontSize={10} tickLine={false} />
                <YAxis stroke="#64748b" fontSize={10} tickLine={false} tickFormatter={(val) => `${val/1000}k`} />
                <Tooltip formatter={(value: number) => [formatIDR(value), '']} />
                <Area type="monotone" dataKey="sales" name="Penjualan" stroke="#E63946" strokeWidth={2} fillOpacity={1} fill="url(#colorSales)" />
                <Area type="monotone" dataKey="expenses" name="Pengeluaran" stroke="#475569" strokeWidth={1.5} fillOpacity={0} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Payment Methods Breakdown */}
        <div className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex flex-col h-[350px]">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Metode Pembayaran</h3>
            <p className="text-[11px] text-slate-500">Distribusi omset berdasarkan tipe bayar</p>
          </div>
          <div className="flex-1 flex items-center justify-center relative text-xs">
            {pieData.length === 0 ? (
              <p className="text-slate-400 font-mono text-xs">Belum ada transaksi</p>
            ) : (
              <div className="w-full h-full flex flex-col justify-center">
                <div className="h-44">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={pieData}
                        cx="50%"
                        cy="50%"
                        innerRadius={50}
                        outerRadius={70}
                        paddingAngle={4}
                        dataKey="value"
                      >
                        {pieData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                        ))}
                      </Pie>
                      <Tooltip formatter={(value: number) => [formatIDR(value), '']} />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
                <div className="flex flex-wrap justify-center gap-x-4 gap-y-1 text-[11px] mt-2">
                  {pieData.map((entry, index) => (
                    <div key={entry.name} className="flex items-center gap-1.5">
                      <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: COLORS[index % COLORS.length] }} />
                      <span className="font-medium text-slate-800">{entry.name}</span>
                      <span className="text-slate-500">({formatIDR(entry.value)})</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Bottom Grid: Top Selling Items and Recent Logs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top Products */}
        <div className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h3 className="text-sm font-bold text-slate-900">5 Menu Terlaris (Top Selling)</h3>
              <p className="text-[11px] text-slate-500">Berdasarkan volume kuantitas porsi yang dipesan</p>
            </div>
            <ArrowUpRight className="w-4 h-4 text-[#E63946]" />
          </div>
          
          {topProducts.length === 0 ? (
            <div className="p-12 text-center text-slate-400 font-mono text-xs">
              Belum ada penjualan porsi makanan.
            </div>
          ) : (
            <div className="space-y-3.5">
              {topProducts.map((p, idx) => (
                <div key={p.name} className="flex items-center justify-between text-xs border-b border-slate-100 pb-3 last:border-0 last:pb-0">
                  <div className="flex items-center gap-3">
                    <span className="w-5 h-5 rounded-full bg-slate-900 text-white font-mono flex items-center justify-center text-[10px] font-bold">
                      {idx + 1}
                    </span>
                    <div>
                      <p className="font-bold text-slate-800">{p.name}</p>
                      <p className="text-[10px] text-[#E63946] font-semibold">{p.qty} Porsi Terjual</p>
                    </div>
                  </div>
                  <p className="font-semibold text-slate-900 font-mono">{formatIDR(p.revenue)}</p>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recent Activity Log */}
        <div className="bg-white border border-slate-200 p-5 rounded-xl shadow-sm flex flex-col h-[280px]">
          <h3 className="text-sm font-bold text-slate-900 mb-1">Aktivitas Sistem POS</h3>
          <p className="text-[11px] text-slate-500 mb-3">Audit log operasional kasir dan administrator</p>
          
          <div className="flex-1 overflow-y-auto space-y-3 text-xs pr-1">
            {logs.slice().reverse().map((log) => (
              <div key={log.id_log} className="flex items-start gap-3 bg-slate-50 p-2.5 rounded border border-slate-100">
                <span className="w-1.5 h-1.5 rounded-full bg-[#E63946] mt-1.5 shrink-0" />
                <div className="space-y-0.5">
                  <p className="text-slate-800 text-xs font-medium">{log.aktivitas}</p>
                  <div className="flex items-center gap-2 text-[9px] text-slate-400 font-mono">
                    <span>IP: {log.ip_address}</span>
                    <span>&bull;</span>
                    <span>{new Date(log.created_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
