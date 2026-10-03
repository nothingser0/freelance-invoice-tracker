import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const supabase = await createClient()

  const {
    data: { session },
  } = await supabase.auth.getSession()

  if (!session) {
    redirect('/login')
  }

  return (
    <div className="min-h-screen bg-zinc-50 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-semibold text-zinc-900 mb-2">
          Dashboard
        </h1>
        <p className="text-zinc-600 mb-8">
          Welcome back, {session.user.email}
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white border border-zinc-200 rounded-lg p-6">
            <h3 className="text-sm font-medium text-zinc-600 mb-2">Total Projects</h3>
            <p className="text-3xl font-semibold text-zinc-900">0</p>
          </div>

          <div className="bg-white border border-zinc-200 rounded-lg p-6">
            <h3 className="text-sm font-medium text-zinc-600 mb-2">Active Invoices</h3>
            <p className="text-3xl font-semibold text-zinc-900">0</p>
          </div>

          <div className="bg-white border border-zinc-200 rounded-lg p-6">
            <h3 className="text-sm font-medium text-zinc-600 mb-2">Total Revenue</h3>
            <p className="text-3xl font-semibold text-zinc-900">$0</p>
          </div>
        </div>

        <div className="mt-8 bg-white border border-zinc-200 rounded-lg p-6">
          <h2 className="text-lg font-semibold text-zinc-900 mb-4">
            Recent Activity
          </h2>
          <p className="text-zinc-500 text-sm">No recent activity</p>
        </div>
      </div>
    </div>
  )
}
