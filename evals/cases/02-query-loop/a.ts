import { db } from "./db";

// The three feature flags the billing page needs. The list is fixed in code.
const FLAG_KEYS = ["invoices_v2", "tax_ids", "dunning"] as const;

export async function loadBillingFlags(): Promise<Record<string, boolean>> {
  const flags: Record<string, boolean> = {};
  for (const key of FLAG_KEYS) {
    const row = await db.query("select enabled from feature_flags where key = $1", [key]);
    flags[key] = row.rows[0]?.enabled ?? false;
  }
  return flags;
}
