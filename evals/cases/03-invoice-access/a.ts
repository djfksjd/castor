import { Router } from "express";
import { db } from "./db";
import { requireLogin } from "./auth"; // authentication only: sets req.session.accountId, 401 otherwise

// `db` connects with the application role, which can read every invoice.
// There is no row-level security, view or wrapper restricting rows by account.

export const router = Router();

router.get("/invoices/:id", requireLogin, async (req, res) => {
  const { rows } = await db.query(
    "select id, account_id, amount_cents, billing_address from invoices where id = $1",
    [req.params.id],
  );
  if (rows.length === 0) return res.status(404).end();
  res.json(rows[0]);
});
