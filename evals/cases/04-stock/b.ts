import { db } from "./db";

// Called by the checkout API; many requests may run at once.
export async function reserveOne(productId: string): Promise<boolean> {
  const { rows } = await db.query("select stock from products where id = $1", [productId]);
  if (rows.length === 0 || rows[0].stock <= 0) return false;
  await db.query("update products set stock = $2 where id = $1", [productId, rows[0].stock - 1]);
  return true;
}
