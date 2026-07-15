import React, { useState } from 'react';
import { 
  Figma, 
  Copy, 
  Check, 
  ExternalLink, 
  Layers, 
  Palette, 
  Code, 
  HelpCircle,
  Sparkles,
  Smartphone,
  Monitor,
  Cpu
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export default function FigmaView() {
  const [copiedUrlType, setCopiedUrlType] = useState<'dev' | 'pre' | 'window' | null>(null);
  const [copiedTokens, setCopiedTokens] = useState(false);
  const [copiedJSON, setCopiedJSON] = useState<string | null>(null);
  const [activeSubTab, setActiveSubTab] = useState<'plugin' | 'tokens' | 'json_schema'>('plugin');

  // Exact URLs for the user to import into figma plugins
  const devUrl = "https://ais-dev-gsbb44saide7l7zsx27kol-425035079450.asia-east1.run.app";
  const previewUrl = "https://ais-pre-gsbb44saide7l7zsx27kol-425035079450.asia-east1.run.app";
  const windowUrl = window.location.href;

  const handleCopyUrl = (url: string, type: 'dev' | 'pre' | 'window') => {
    navigator.clipboard.writeText(url);
    setCopiedUrlType(type);
    setTimeout(() => setCopiedUrlType(null), 2000);
  };

  // Figma Variables / Tokens in standardized JSON format (Token Studio style)
  const designTokens = {
    "colors": {
      "brand": {
        "primary": { "value": "#E63946", "type": "color", "description": "Sushimoo brand primary crimson red" },
        "primary_hover": { "value": "#ff4d5a", "type": "color" },
        "dark": { "value": "#1A1A1A", "type": "color", "description": "Brand dark charcoal slate" }
      },
      "neutral": {
        "canvas": { "value": "#F1F5F9", "type": "color" },
        "card": { "value": "#FFFFFF", "type": "color" },
        "border": { "value": "#E2E8F0", "type": "color" },
        "text_main": { "value": "#0F172A", "type": "color" },
        "text_muted": { "value": "#64748B", "type": "color" }
      },
      "semantic": {
        "success": { "value": "#10B981", "type": "color" },
        "warning": { "value": "#F59E0B", "type": "color" },
        "danger": { "value": "#EF4444", "type": "color" }
      }
    },
    "typography": {
      "fontFamilies": {
        "sans": { "value": "Inter, sans-serif", "type": "fontFamily" },
        "mono": { "value": "JetBrains Mono, monospace", "type": "fontFamily" }
      },
      "fontSizes": {
        "xs": { "value": "12px", "type": "fontSize" },
        "sm": { "value": "14px", "type": "fontSize" },
        "base": { "value": "16px", "type": "fontSize" },
        "lg": { "value": "18px", "type": "fontSize" },
        "xl": { "value": "20px", "type": "fontSize" }
      }
    },
    "borderRadius": {
      "none": { "value": "0px", "type": "borderRadius" },
      "sm": { "value": "4px", "type": "borderRadius" },
      "md": { "value": "8px", "type": "borderRadius" },
      "lg": { "value": "12px", "type": "borderRadius" },
      "xl": { "value": "16px", "type": "borderRadius" }
    }
  };

  const handleCopyTokens = () => {
    navigator.clipboard.writeText(JSON.stringify(designTokens, null, 2));
    setCopiedTokens(true);
    setTimeout(() => setCopiedTokens(false), 2000);
  };

  // Helper mock figma layers code structure for a beautiful product card component
  const figmaComponentCode = {
    "type": "FRAME",
    "name": "Sushimoo Product Card",
    "width": 280,
    "height": 160,
    "fills": [{ "type": "SOLID", "color": { "r": 1, "g": 1, "b": 1 } }],
    "cornerRadius": 12,
    "strokeWeight": 1,
    "strokes": [{ "type": "SOLID", "color": { "r": 0.88, "g": 0.91, "b": 0.94 } }],
    "layoutMode": "VERTICAL",
    "paddingLeft": 16,
    "paddingRight": 16,
    "paddingTop": 16,
    "paddingBottom": 16,
    "itemSpacing": 12,
    "children": [
      {
        "type": "TEXT",
        "name": "nama_produk",
        "characters": "Spicy Salmon Roll XL",
        "fontSize": 14,
        "fontName": { "family": "Inter", "style": "Bold" },
        "fills": [{ "type": "SOLID", "color": { "r": 0.09, "g": 0.11, "b": 0.16 } }]
      },
      {
        "type": "TEXT",
        "name": "harga",
        "characters": "Rp 45.000",
        "fontSize": 12,
        "fontName": { "family": "JetBrains Mono", "style": "Medium" },
        "fills": [{ "type": "SOLID", "color": { "r": 0.9, "g": 0.22, "b": 0.27 } }]
      }
    ]
  };

  const handleCopyJSONSchema = (key: string, schema: object) => {
    navigator.clipboard.writeText(JSON.stringify(schema, null, 2));
    setCopiedJSON(key);
    setTimeout(() => setCopiedJSON(null), 2000);
  };

  return (
    <div id="figma-view" className="max-w-4xl mx-auto space-y-6">
      
      {/* Title block */}
      <div className="bg-white border border-slate-200/80 p-5 rounded-xl shadow-sm">
        <div className="flex items-center gap-2.5">
          <div className="w-9 h-9 rounded-lg bg-[#E63946] flex items-center justify-center text-white shadow-sm">
            <Figma className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-slate-900 tracking-tight flex items-center gap-1.5">
              Figma Integration Center
            </h2>
            <p className="text-slate-500 text-xs">Salin dan ekspor antarmuka Sushimoo POS secara presisi ke kanvas desain Figma.</p>
          </div>
        </div>
      </div>

      {/* Sub-tab selection */}
      <div className="flex bg-white border border-slate-200 p-1.5 rounded-xl shadow-sm text-xs gap-1">
        <button
          onClick={() => setActiveSubTab('plugin')}
          className={`flex-1 sm:flex-initial px-4 py-2.5 rounded-lg font-bold flex items-center justify-center gap-2 transition-all ${activeSubTab === 'plugin' ? 'bg-[#1A1A1A] text-white shadow' : 'text-slate-600 hover:text-slate-900'}`}
        >
          <Layers className="w-4 h-4" /> 
          <span>Figma Plugin (Import Live UI)</span>
        </button>
        <button
          onClick={() => setActiveSubTab('tokens')}
          className={`flex-1 sm:flex-initial px-4 py-2.5 rounded-lg font-bold flex items-center justify-center gap-2 transition-all ${activeSubTab === 'tokens' ? 'bg-[#1A1A1A] text-white shadow' : 'text-slate-600 hover:text-slate-900'}`}
        >
          <Palette className="w-4 h-4" /> 
          <span>Design Tokens (JSON Variables)</span>
        </button>
        <button
          onClick={() => setActiveSubTab('json_schema')}
          className={`flex-1 sm:flex-initial px-4 py-2.5 rounded-lg font-bold flex items-center justify-center gap-2 transition-all ${activeSubTab === 'json_schema' ? 'bg-[#1A1A1A] text-white shadow' : 'text-slate-600 hover:text-slate-900'}`}
        >
          <Code className="w-4 h-4" /> 
          <span>Figma Layout Schema (JSON Layers)</span>
        </button>
      </div>

      {/* SUB-PAGES */}
      <AnimatePresence mode="wait">
        {activeSubTab === 'plugin' && (
          <motion.div
            key="plugin-view"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="grid grid-cols-1 md:grid-cols-12 gap-6 items-stretch"
          >
            {/* Guide column (7 cols) */}
            <div className="md:col-span-7 bg-white border border-slate-200 rounded-xl p-5 shadow-sm space-y-5">
              <h3 className="font-bold text-slate-900 text-xs uppercase tracking-wider text-slate-400 border-b border-slate-100 pb-2">
                Panduan Impor Langsung dengan Plugin Figma
              </h3>

              <div className="space-y-4 text-xs text-slate-700 leading-relaxed">
                <div className="flex gap-3">
                  <div className="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center font-mono font-bold text-slate-600 shrink-0 mt-0.5 text-[10px]">
                    1
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 mb-0.5">Buka Kanvas Figma Anda</p>
                    <p className="text-slate-500">Buka software Figma desktop atau web, buat atau pilih file proyek desain baru Anda.</p>
                  </div>
                </div>

                <div className="flex gap-3">
                  <div className="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center font-mono font-bold text-slate-600 shrink-0 mt-0.5 text-[10px]">
                    2
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 mb-0.5">Jalankan Plugin "html.to.design"</p>
                    <p className="text-slate-500">
                      Cari di tab Plugins Figma kata kunci <span className="font-bold text-slate-800 bg-slate-100 px-1.5 py-0.5 rounded">html.to.design</span> (oleh h2d) atau <span className="font-bold text-slate-800 bg-slate-100 px-1.5 py-0.5 rounded">Builder.io - HTML to Figma</span>. Jalankan plugin tersebut.
                    </p>
                  </div>
                </div>

                <div className="flex gap-3">
                  <div className="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center font-mono font-bold text-slate-600 shrink-0 mt-0.5 text-[10px]">
                    3
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 mb-0.5">Salin URL Aplikasi yang Terbuka saat ini</p>
                    <p className="text-slate-500">Gunakan tombol copy di sebelah kanan untuk menyalin URL sandbox aplikasi web Sushimoo POS Anda.</p>
                  </div>
                </div>

                <div className="flex gap-3">
                  <div className="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center font-mono font-bold text-slate-600 shrink-0 mt-0.5 text-[10px]">
                    4
                  </div>
                  <div>
                    <p className="font-bold text-slate-900 mb-0.5">Tempel URL & Klik "Import"</p>
                    <p className="text-slate-500">Masukkan URL tersebut pada kolom input di plugin Figma, tentukan opsi resolusi (Desktop/Laptop), lalu klik tombol Import. Seluruh layer HTML/CSS akan direkonstruksi menjadi Layer Figma Autolayout yang rapi dan siap diedit!</p>
                  </div>
                </div>
              </div>
            </div>

            {/* URL Clipboard Copy (5 cols) */}
            <div className="md:col-span-5 bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex flex-col justify-between space-y-6">
              <div className="space-y-5">
                <h3 className="font-bold text-slate-900 text-xs uppercase tracking-wider text-slate-400 border-b border-slate-100 pb-2">
                  Salin URL Aplikasi
                </h3>

                {/* Option 1: Development URL */}
                <div className="space-y-1.5">
                  <div className="flex justify-between items-center">
                    <span className="text-[10px] uppercase tracking-wider text-slate-500 font-extrabold font-mono">
                      1. Dev URL (Recommended)
                    </span>
                    <span className="text-[9px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.5 rounded">Fastest</span>
                  </div>
                  <div className="p-2.5 bg-slate-50 border border-slate-200 rounded font-mono text-[10px] text-slate-600 break-all select-all">
                    {devUrl}
                  </div>
                  <button
                    onClick={() => handleCopyUrl(devUrl, 'dev')}
                    className={`w-full py-1.5 text-white font-bold text-[10px] uppercase tracking-widest rounded transition-all flex items-center justify-center gap-1.5 shadow-sm ${copiedUrlType === 'dev' ? 'bg-emerald-600' : 'bg-slate-900 hover:bg-slate-800'}`}
                  >
                    {copiedUrlType === 'dev' ? (
                      <><Check className="w-3.5 h-3.5" /> Dev URL Berhasil Disalin</>
                    ) : (
                      <><Copy className="w-3.5 h-3.5" /> Salin Dev URL</>
                    )}
                  </button>
                </div>

                {/* Option 2: Shared Preview URL */}
                <div className="space-y-1.5">
                  <div className="flex justify-between items-center">
                    <span className="text-[10px] uppercase tracking-wider text-slate-500 font-extrabold font-mono">
                      2. Shared Preview URL
                    </span>
                    <span className="text-[9px] bg-slate-100 text-slate-600 px-1.5 py-0.5 rounded">Stable</span>
                  </div>
                  <div className="p-2.5 bg-slate-50 border border-slate-200 rounded font-mono text-[10px] text-slate-600 break-all select-all">
                    {previewUrl}
                  </div>
                  <button
                    onClick={() => handleCopyUrl(previewUrl, 'pre')}
                    className={`w-full py-1.5 text-white font-bold text-[10px] uppercase tracking-widest rounded transition-all flex items-center justify-center gap-1.5 shadow-sm ${copiedUrlType === 'pre' ? 'bg-emerald-600' : 'bg-slate-900 hover:bg-slate-800'}`}
                  >
                    {copiedUrlType === 'pre' ? (
                      <><Check className="w-3.5 h-3.5" /> Preview URL Berhasil Disalin</>
                    ) : (
                      <><Copy className="w-3.5 h-3.5" /> Salin Preview URL</>
                    )}
                  </button>
                </div>
              </div>

              <div className="space-y-3 pt-4 border-t border-slate-100">
                <div className="flex justify-center items-center gap-1 text-[10px] text-slate-400 font-mono">
                  <Sparkles className="w-3.5 h-3.5 text-amber-500" />
                  <span>Dukungan penuh untuk Figma Autolayout</span>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {activeSubTab === 'tokens' && (
          <motion.div
            key="tokens-view"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm space-y-4"
          >
            <div className="flex justify-between items-center border-b border-slate-100 pb-3">
              <div>
                <h3 className="font-bold text-slate-900 text-sm">Figma Variables / Design Tokens</h3>
                <p className="text-slate-500 text-xs">Desain token format JSON yang kompatibel dengan plugin <strong>Token Studio</strong> / <strong>Figma Variables</strong>.</p>
              </div>
              <button
                onClick={handleCopyTokens}
                className={`px-3 py-1.5 rounded text-xs font-bold text-white transition-all flex items-center gap-1.5 ${copiedTokens ? 'bg-emerald-600' : 'bg-slate-900 hover:bg-slate-800'}`}
              >
                {copiedTokens ? (
                  <>
                    <Check className="w-3.5 h-3.5" /> Terkopas
                  </>
                ) : (
                  <>
                    <Copy className="w-3.5 h-3.5" /> Salin Token JSON
                  </>
                )}
              </button>
            </div>

            <div className="max-h-[300px] overflow-y-auto bg-slate-950 rounded-lg p-4 text-slate-300 font-mono text-[10px] leading-relaxed select-all">
              <pre>{JSON.stringify(designTokens, null, 2)}</pre>
            </div>
          </motion.div>
        )}

        {activeSubTab === 'json_schema' && (
          <motion.div
            key="json-view"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="space-y-6"
          >
            {/* Cards for schema presets */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              
              {/* Card 1: Product Card Layout */}
              <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex flex-col justify-between">
                <div>
                  <h4 className="font-bold text-slate-900 text-xs uppercase tracking-wider text-slate-400 mb-1">
                    Preset: Sushimoo Menu Card Layer
                  </h4>
                  <p className="text-slate-500 text-xs leading-relaxed">
                    Struktur layer figma dalam format JSON murni untuk membuat layout card produk ramen/sushi, lengkap dengan padding, margin, fill, dan text.
                  </p>
                </div>
                <div className="mt-4 pt-4 border-t border-slate-100">
                  <button
                    onClick={() => handleCopyJSONSchema('menu_card', figmaComponentCode)}
                    className={`w-full py-2 rounded text-xs font-bold text-white transition-all flex items-center justify-center gap-1.5 ${copiedJSON === 'menu_card' ? 'bg-emerald-600' : 'bg-[#1A1A1A] hover:bg-[#2b2b2b]'}`}
                  >
                    {copiedJSON === 'menu_card' ? (
                      <>
                        <Check className="w-3.5 h-3.5" /> Berhasil Disalin!
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5" /> Salin Figma JSON Layer
                      </>
                    )}
                  </button>
                </div>
              </div>

              {/* Card 2: Receipt layout */}
              <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm flex flex-col justify-between">
                <div>
                  <h4 className="font-bold text-slate-900 text-xs uppercase tracking-wider text-slate-400 mb-1">
                    Preset: Struk Slip Receipt (Thermal)
                  </h4>
                  <p className="text-slate-500 text-xs leading-relaxed">
                    Spesifikasi Autolayout frame struk kertas kasir mini thermal 80mm Sushimoo POS, pas untuk pencocokan desain pixel-perfect di Figma.
                  </p>
                </div>
                <div className="mt-4 pt-4 border-t border-slate-100">
                  <button
                    onClick={() => handleCopyJSONSchema('receipt', {
                      "type": "FRAME",
                      "name": "Sushimoo Thermal Slip 80mm",
                      "width": 300,
                      "height": 450,
                      "fills": [{ "type": "SOLID", "color": { "r": 1, "g": 1, "b": 1 } }],
                      "layoutMode": "VERTICAL",
                      "paddingLeft": 20,
                      "paddingRight": 20,
                      "paddingTop": 30,
                      "paddingBottom": 30,
                      "itemSpacing": 16,
                      "children": [
                        { "type": "TEXT", "characters": "SUSHIMOO RESTORAN", "fontName": { "family": "Inter", "style": "Bold" }, "fontSize": 14 },
                        { "type": "TEXT", "characters": "Rekonsiliasi Keuangan Harian", "fontSize": 10 }
                      ]
                    })}
                    className={`w-full py-2 rounded text-xs font-bold text-white transition-all flex items-center justify-center gap-1.5 ${copiedJSON === 'receipt' ? 'bg-emerald-600' : 'bg-[#1A1A1A] hover:bg-[#2b2b2b]'}`}
                  >
                    {copiedJSON === 'receipt' ? (
                      <>
                        <Check className="w-3.5 h-3.5" /> Berhasil Disalin!
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5" /> Salin Figma JSON Layer
                      </>
                    )}
                  </button>
                </div>
              </div>

            </div>
          </motion.div>
        )}
      </AnimatePresence>

    </div>
  );
}
