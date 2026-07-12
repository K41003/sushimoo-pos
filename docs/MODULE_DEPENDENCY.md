# Module Dependency Diagram — Flutter (GetX)

```
                         ┌─────────────────────────┐
                         │   app/services          │
                         │  ApiClient(Dio) · Auth  │
                         │  Storage · Printer      │
                         └────────────┬────────────┘
                                      │ used by every module
        ┌──────────────┬─────────────┼──────────────┬───────────────┐
        ▼              ▼             ▼              ▼               ▼
   ┌─────────┐   ┌──────────┐  ┌───────────┐  ┌───────────┐  ┌──────────┐
   │ splash  │   │  login   │  │ dashboard │  │  setting  │  │  report  │
   └────┬────┘   └────┬─────┘  └─────┬─────┘  └─────┬─────┘  └─────┬────┘
        │             │             │              │              │
        │        AuthService        │              │              │
        │             │             │              │              │
        ▼             ▼             ▼              ▼              ▼
   category ◄──► product ◄──► ingredient ◄──► stock      closing ◄── expense
        │             │              │              │              │
        └─────┬───────┴──────┬───────┴──────────────┘              │
              ▼              ▼                                       │
          table ────► shift ────► pos ────► cart ────► payment ─────┘
                              │
                              ▼
                        printer service
                     (kitchen / receipt / closing)
```

## Dependency Rules
- `shared/widgets/*` are leaf components — depend only on `theme` + `constants`.
- `data/*` (models, providers, repositories, response) depend only on `services/ApiClient`.
- Modules depend on `data/*` + `shared/*` + `app/services/*`; modules never import each other's controllers directly — they navigate by route.
- `pos` depends on `category`, `product`, `table`, `cart` (as sub-widgets) and triggers `payment`.
- `payment` depends on `printer_service` for receipt printing.
- `closing` depends on `expense`, `shift`, `report`, and `printer_service` (closing report).

## Cross-Cutting (Phase-dependent)
- Phase 1: splash, login, app shell, auth service, api client, theme, constants.
- Phase 2: category, product, ingredient, stock.
- Phase 3: table, shift.
- Phase 4: pos (categories+grid), cart, payment.
- Phase 5: expense, closing.
- Phase 6: report (+ dashboard cards/charts, statistics, last-7-days).
- Phase 7: printer_service (thermal) — injected into payment & closing.
- Phase 8: widget/unit tests for the above.

## Roles → Module visibility
- Admin: dashboard(admin), category, product, ingredient, stock, table, report, closing(history), setting.
- Cashier: dashboard(cashier), shift, table(select), pos, cart, payment, expense, report(daily/last-7), closing.
