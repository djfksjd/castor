import { db } from "./db";

// Called by the checkout API; many requests may run at once.
export async function reserveOne(productId: string): Promise<boolean> {
  const res = await db.query(
    "update products set stock = stock - 1 where id = $1 and stock > 0",
    [productId],
  );
  return res.rowCount === 1;
}
