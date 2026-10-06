import { db } from "./db";

// Dashboard: every order of the signed-in account with its line items.
export async function loadOrders(accountId: string) {
  const orders = await db.query(
    "select id, created_at, total_cents from orders where account_id = $1 order by created_at desc",
    [accountId],
  );
  const result = [];
  for (const order of orders.rows) {
    const items = await db.query(
      "select sku, qty, price_cents from order_items where order_id = $1",
      [order.id],
    );
    result.push({ ...order, items: items.rows });
  }
  return result;
}
