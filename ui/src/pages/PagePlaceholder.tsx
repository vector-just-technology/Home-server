import { useLocation } from 'react-router-dom'
import { Wrench } from 'lucide-react'

const pageInfo: Record<string, { icon: string; desc: string }> = {
  '/videos': { icon: '🎬', desc: 'Browse and stream your video collection' },
  '/photos': { icon: '🖼️', desc: 'View and manage your photo gallery' },
  '/podcasts': { icon: '🎙️', desc: 'Listen to your podcast subscriptions' },
  '/calendar': { icon: '📅', desc: 'Manage events and schedules' },
  '/calculator': { icon: '🧮', desc: 'Perform calculations and conversions' },
  '/recent': { icon: '🕐', desc: 'Recently accessed files and documents' },
  '/favorites': { icon: '⭐', desc: 'Your starred and bookmarked items' },
  '/files': { icon: '📁', desc: 'Full file manager with folder navigation' },
  '/permissions': { icon: '🔐', desc: 'Manage user roles and access controls' },
  '/audit': { icon: '📋', desc: 'System activity and security audit log' },
  '/backup': { icon: '💾', desc: 'Configure automated backup schedules' },
  '/encryption': { icon: '🔑', desc: 'Manage encryption keys and settings' },
  '/admin': { icon: '⚙️', desc: 'Administrative panel and system settings' },
  '/music': { icon: '🎵', desc: 'Your music library and playlists' },
  '/network': { icon: '🌐', desc: 'Network topology and interface management' },
}

export default function PagePlaceholder() {
  const location = useLocation()
  const info = pageInfo[location.pathname] || { icon: '🚧', desc: 'This page is under construction' }
  const name = location.pathname.split('/').filter(Boolean).pop() || 'Page'
  const title = name.charAt(0).toUpperCase() + name.slice(1).replace(/-/g, ' ')

  return (
    <div style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
      height: '100%', gap: 20, padding: 40, textAlign: 'center'
    }}>
      <div style={{ fontSize: 64, lineHeight: 1 }}>{info.icon}</div>
      <h1 style={{ fontSize: 28, fontWeight: 700, margin: 0 }}>{title}</h1>
      <p style={{ color: 'var(--text-secondary)', fontSize: 15, maxWidth: 400, lineHeight: 1.6, margin: 0 }}>{info.desc}</p>
      <div style={{
        marginTop: 12, padding: '12px 24px', borderRadius: 10,
        background: 'var(--accent-dim)', color: 'var(--accent)',
        fontSize: 13, display: 'flex', alignItems: 'center', gap: 8
      }}>
        <Wrench size={16} /> Coming in the next update
      </div>
    </div>
  )
}
