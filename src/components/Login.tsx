import React, { useState } from 'react';
import { User, ShieldCheck, CreditCard, Lock, Sparkles } from 'lucide-react';
import { motion } from 'motion/react';
import { User as UserType } from '../types';

interface LoginProps {
  users: UserType[];
  onLogin: (user: UserType) => void;
}

export default function Login({ users, onLogin }: LoginProps) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleManualLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const trimmedUser = username.trim().toLowerCase();
    const user = users.find(u => u.username === trimmedUser && u.status === 1);

    if (user) {
      // Allow any password in simulation but check if filled
      if (!password) {
        setError('Silakan masukkan password.');
        return;
      }
      onLogin(user);
    } else {
      setError('Username tidak ditemukan atau akun dinonaktifkan.');
    }
  };

  const handleQuickLogin = (roleName: 'Admin' | 'Kasir') => {
    const roleId = roleName === 'Admin' ? 1 : 2;
    const user = users.find(u => u.id_role === roleId && u.status === 1);
    if (user) {
      onLogin(user);
    }
  };

  return (
    <div id="login-screen" className="min-h-screen flex items-center justify-center bg-[#131313] p-4 relative overflow-hidden font-sans">
      {/* Zen Ambient Background Accents */}
      <div className="absolute top-[-20%] left-[-10%] w-[600px] h-[600px] rounded-full bg-[#E63946] opacity-[0.03] blur-[120px]" />
      <div className="absolute bottom-[-20%] right-[-10%] w-[600px] h-[600px] rounded-full bg-[#E63946] opacity-[0.02] blur-[120px]" />

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-md bg-[#1c1c1c] rounded-xl border border-white/[0.06] p-8 shadow-2xl relative"
      >
        {/* Japanese Accent Stamp */}
        <div className="absolute top-6 right-8 w-8 h-8 rounded bg-[#E63946] flex items-center justify-center text-white text-[11px] font-bold tracking-widest font-serif leading-none select-none">
          寿司
        </div>

        <div className="text-center mb-8">
          <p className="text-[#E63946] uppercase tracking-[0.2em] text-xs font-semibold mb-1">Point of Sale System</p>
          <h1 className="text-3xl font-extrabold tracking-tight text-white mb-2">
            SUSHIMOO <span className="text-[#E63946]">.</span>
          </h1>
          <p className="text-[#94a3b8] text-xs font-mono">Zen Precision Restaurant POS</p>
        </div>

        {error && (
          <motion.div 
            initial={{ opacity: 0, y: -5 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-4 p-3 rounded bg-red-950/40 border border-red-500/20 text-red-400 text-xs text-center"
          >
            {error}
          </motion.div>
        )}

        <form onSubmit={handleManualLogin} className="space-y-4">
          <div>
            <label className="block text-xs uppercase tracking-wider text-slate-400 font-semibold mb-1">Username</label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
              <input
                id="login-username"
                type="text"
                value={username}
                onChange={e => setUsername(e.target.value)}
                placeholder="Masukkan username (admin / kasir)"
                className="w-full pl-10 pr-4 py-3 bg-[#131313] border border-slate-800 rounded focus:border-[#E63946] focus:outline-none text-white text-sm transition-colors"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs uppercase tracking-wider text-slate-400 font-semibold mb-1">Password</label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
              <input
                id="login-password"
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full pl-10 pr-4 py-3 bg-[#131313] border border-slate-800 rounded focus:border-[#E63946] focus:outline-none text-white text-sm transition-colors"
              />
            </div>
          </div>

          <button
            id="login-submit"
            type="submit"
            className="w-full py-3 bg-[#E63946] hover:bg-[#ff4d5a] text-white font-medium text-sm rounded shadow transition-colors duration-200 mt-2"
          >
            Masuk ke Sistem
          </button>
        </form>

        <div className="relative my-6 text-center">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-slate-800" />
          </div>
          <span className="relative bg-[#1c1c1c] px-3 text-[10px] text-slate-500 font-mono uppercase tracking-widest">
            Uji Coba Cepat
          </span>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <button
            id="login-preset-admin"
            type="button"
            onClick={() => handleQuickLogin('Admin')}
            className="flex flex-col items-center p-3 bg-slate-900/60 hover:bg-slate-900 border border-slate-800 hover:border-slate-700 rounded transition-all text-left"
          >
            <ShieldCheck className="w-5 h-5 text-[#E63946] mb-1.5" />
            <span className="text-white text-xs font-semibold">Role Admin</span>
            <span className="text-[10px] text-slate-500 font-mono mt-0.5">user: admin</span>
          </button>

          <button
            id="login-preset-kasir"
            type="button"
            onClick={() => handleQuickLogin('Kasir')}
            className="flex flex-col items-center p-3 bg-slate-900/60 hover:bg-slate-900 border border-slate-800 hover:border-slate-700 rounded transition-all text-left"
          >
            <CreditCard className="w-5 h-5 text-emerald-400 mb-1.5" />
            <span className="text-white text-xs font-semibold">Role Kasir</span>
            <span className="text-[10px] text-slate-500 font-mono mt-0.5">user: kasir</span>
          </button>
        </div>

        <div className="mt-8 text-center">
          <p className="text-[10px] text-slate-600 font-mono flex items-center justify-center gap-1.5">
            <Sparkles className="w-3 h-3 text-[#E63946]" /> 
            Sushimoo POS v1.0.0 &bull; 2026
          </p>
        </div>
      </motion.div>
    </div>
  );
}
