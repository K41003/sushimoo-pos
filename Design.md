---
name: Shushimoo POS
colors:
  surface: "#131313"
  surface-dim: "#131313"
  surface-bright: "#393939"
  surface-container-lowest: "#0e0e0e"
  surface-container-low: "#1b1c1c"
  surface-container: "#1f2020"
  surface-container-high: "#2a2a2a"
  surface-container-highest: "#353535"
  on-surface: "#e4e2e1"
  on-surface-variant: "#e4bebc"
  inverse-surface: "#e4e2e1"
  inverse-on-surface: "#303030"
  outline: "#ab8987"
  outline-variant: "#5b403f"
  surface-tint: "#ffb3b1"
  primary: "#ffb3b1"
  on-primary: "#680011"
  primary-container: "#ff535b"
  on-primary-container: "#5b000e"
  inverse-primary: "#bb152c"
  secondary: "#c8c6c5"
  on-secondary: "#313030"
  secondary-container: "#474746"
  on-secondary-container: "#b7b5b4"
  tertiary: "#c6c6c7"
  on-tertiary: "#2f3131"
  tertiary-container: "#909191"
  on-tertiary-container: "#282a2a"
  error: "#ffb4ab"
  on-error: "#690005"
  error-container: "#93000a"
  on-error-container: "#ffdad6"
  primary-fixed: "#ffdad8"
  primary-fixed-dim: "#ffb3b1"
  on-primary-fixed: "#410007"
  on-primary-fixed-variant: "#92001c"
  secondary-fixed: "#e5e2e1"
  secondary-fixed-dim: "#c8c6c5"
  on-secondary-fixed: "#1c1b1b"
  on-secondary-fixed-variant: "#474746"
  tertiary-fixed: "#e2e2e2"
  tertiary-fixed-dim: "#c6c6c7"
  on-tertiary-fixed: "#1a1c1c"
  on-tertiary-fixed-variant: "#454747"
  background: "#131313"
  on-background: "#e4e2e1"
  surface-variant: "#353535"
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: "700"
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: "600"
    lineHeight: 40px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: "600"
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: "400"
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "600"
    lineHeight: 20px
    letterSpacing: 0.05em
  price-display:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: "700"
    lineHeight: 32px
    letterSpacing: -0.01em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
  rail-width: 80px
  sidebar-width: 320px
---

## Brand & Style

The brand personality is centered on "Zen Precision"—a harmonious blend of traditional Japanese craftsmanship and modern technical efficiency. It aims to evoke a sense of calm, order, and mastery, essential for high-pressure hospitality environments.

The design style utilizes **Minimalism** with a **Corporate Modern** edge. By emphasizing heavy whitespace (or "Ma" in Japanese design), the UI reduces cognitive load for servers and chefs. The aesthetic is sharp and intentional, prioritizing legibility and swift interaction through a restricted color palette and rigorous alignment.

## Colors

The palette is rooted in the traditional lacquerware colors of Japan: Crimson, Ink, and Paper.

- **Primary (Crimson):** Used sparingly for critical calls to action, active states, and branding accents. It signifies urgency and energy.
- **Secondary (Ink):** The foundation of the interface. A deep, desaturated black used for backgrounds to minimize eye strain in dim restaurant environments.
- **Tertiary/Neutral (Paper/Stone):** High-contrast whites and subtle grays are used for primary text and secondary UI surfaces, ensuring maximum readability under varied lighting.
- **Functional Colors:** Success (Green) and Warning (Amber) are used only for status indicators, maintaining the integrity of the core triad.

## Typography

This design system relies exclusively on **Inter** for its neutral, systematic clarity.

Typography is used to create a strict information hierarchy. **Display and Headline** roles are used for order totals and category titles. **Price-display** is a specialized role optimized for numerical clarity at a glance. On tablet devices, base body sizes are increased to 18px to ensure legibility when the device is mounted on a stand or held at arm's length. All labels use increased letter spacing and uppercase styling to distinguish metadata from user content.

## Layout & Spacing

The layout employs a **Fluid Grid** system tailored for tablet ergonomics.

- **Landscape Orientation:** Utilizes a 12-column grid. The primary pattern is a **Navigation Rail** (fixed 80px) on the far left, a **Master View** (6 columns) for menu selection, and a **Detail View/Cart** (remaining columns) on the right.
- **Portrait Orientation:** Switches to an 8-column grid. The layout prioritizes a vertical stack or a collapsible sidebar for the cart to maximize the menu grid area.
- **Touch Targets:** All interactive elements maintain a minimum hit area of 48x48px. Spacing between interactive elements (gutters) is strictly 16px to prevent accidental taps.

## Elevation & Depth

Depth is conveyed through **Tonal Layers** and **Low-contrast Outlines** rather than heavy shadows, maintaining the flat, Zen aesthetic.

- **Level 0 (Base):** The darkest surface (#1A1A1A), used for the main background.
- **Level 1 (Surface):** A slightly lighter tint (#2B2B2B) used for cards, menu items, and input fields.
- **Level 2 (Overlay):** Used for modals or pop-overs, featuring a subtle 1px border (#FFFFFF, 10% opacity) to define edges against the background.
- **Active States:** Indicated by a high-contrast shift (Inner glow or Primary Red border) rather than a physical lift.

## Shapes

Shapes follow a **Soft (Level 1)** logic.

A 4px border radius is the standard for most components (Buttons, Inputs, Cards). This small radius maintains the "precision" aspect of the brand while slightly softening the clinical nature of a pure 0px edge. Larger containers, such as the Cart Sidebar or Modal overlays, use a 12px (rounded-xl) radius on inner-facing corners to create a clear visual containment.

## Components

- **Buttons:** Primary buttons are solid Red with white text. Secondary buttons are outlined. Height is fixed at 56px for tablet touch-readiness.
- **Chips:** Used for dietary filters (e.g., GF, Vegan). These use a "Paper" background with "Ink" text for high visibility.
- **Lists:** Order lists use 72px row heights to accommodate large text and "Quantity" steppers.
- **Input Fields:** Steppers (Plus/Minus) are oversized (64px width) to ensure fast, error-free adjustments during order entry.
- **Cards:** Menu item cards feature a 1:1 aspect ratio image placeholder or a bold typographic shorthand.
- **Navigation Rail:** A vertical bar containing large icons with labels below, providing persistent access to Tables, Menu, and Settings.

---

name: Sushimoo POS
colors:
surface: '#f9f9f9'
surface-dim: '#dadada'
surface-bright: '#f9f9f9'
surface-container-lowest: '#ffffff'
surface-container-low: '#f3f3f3'
surface-container: '#eeeeee'
surface-container-high: '#e8e8e8'
surface-container-highest: '#e2e2e2'
on-surface: '#1a1c1c'
on-surface-variant: '#444748'
inverse-surface: '#2f3131'
inverse-on-surface: '#f1f1f1'
outline: '#747878'
outline-variant: '#c4c7c7'
surface-tint: '#5f5e5e'
primary: '#000000'
on-primary: '#ffffff'
primary-container: '#1c1b1b'
on-primary-container: '#858383'
inverse-primary: '#c8c6c5'
secondary: '#b7102a'
on-secondary: '#ffffff'
secondary-container: '#db313f'
on-secondary-container: '#fffbff'
tertiary: '#000000'
on-tertiary: '#ffffff'
tertiary-container: '#1a1c1c'
on-tertiary-container: '#838484'
error: '#ba1a1a'
on-error: '#ffffff'
error-container: '#ffdad6'
on-error-container: '#93000a'
primary-fixed: '#e5e2e1'
primary-fixed-dim: '#c8c6c5'
on-primary-fixed: '#1c1b1b'
on-primary-fixed-variant: '#474746'
secondary-fixed: '#ffdad8'
secondary-fixed-dim: '#ffb3b1'
on-secondary-fixed: '#410007'
on-secondary-fixed-variant: '#92001c'
tertiary-fixed: '#e2e2e2'
tertiary-fixed-dim: '#c6c6c7'
on-tertiary-fixed: '#1a1c1c'
on-tertiary-fixed-variant: '#454747'
background: '#f9f9f9'
on-background: '#1a1c1c'
surface-variant: '#e2e2e2'
typography:
display-lg:
fontFamily: Inter
fontSize: 40px
fontWeight: '700'
lineHeight: 48px
letterSpacing: -0.02em
headline-lg:
fontFamily: Inter
fontSize: 32px
fontWeight: '600'
lineHeight: 40px
letterSpacing: -0.01em
headline-lg-mobile:
fontFamily: Inter
fontSize: 24px
fontWeight: '600'
lineHeight: 32px
headline-md:
fontFamily: Inter
fontSize: 20px
fontWeight: '600'
lineHeight: 28px
body-lg:
fontFamily: Inter
fontSize: 18px
fontWeight: '400'
lineHeight: 26px
body-md:
fontFamily: Inter
fontSize: 16px
fontWeight: '400'
lineHeight: 24px
label-lg:
fontFamily: Inter
fontSize: 14px
fontWeight: '600'
lineHeight: 20px
letterSpacing: 0.05em
label-sm:
fontFamily: Inter
fontSize: 12px
fontWeight: '500'
lineHeight: 16px
letterSpacing: 0.02em
rounded:
sm: 0.25rem
DEFAULT: 0.5rem
md: 0.75rem
lg: 1rem
xl: 1.5rem
full: 9999px
spacing:
unit: 8px
container-margin: 16px
gutter: 12px
touch-target-min: 44px
card-padding: 20px

---

## Brand & Style

The design system is rooted in the philosophy of _Ma_ (negative space) and functional efficiency. Designed for high-pressure culinary environments, it balances a "Zen" aesthetic with clinical precision. The personality is disciplined yet welcoming, prioritizing clarity over decoration.

The aesthetic is **Minimalist-Modern** with a focus on tactile clarity. It utilizes heavy whitespace to reduce cognitive load for sushi chefs and servers, ensuring that the most critical information—the order status and the guest's needs—remains the primary focus. The interface should feel as balanced and intentional as a well-plated Omakase set.

## Colors

The palette is inspired by the essential elements of Japanese cuisine.

- **Sumie Black (#1A1A1A):** Used for primary text, deep borders, and high-emphasis backgrounds. It provides the "ink" that defines the structure.
- **Sushi Red (#E63946):** The primary accent color. Used sparingly for critical calls to action (e.g., "Place Order"), active states, and alerts.
- **Rice White (#FDFDFD):** The foundation of the UI. It provides a clean, breathable canvas.
- **Matcha Green (#A8DADC):** Reserved exclusively for success states, completed orders, and positive financial indicators.
- **Ink Gray (#757575):** Used for secondary text and disabled states to maintain low visual noise.

## Typography

This design system uses **Inter** for its exceptional legibility on small screens and its neutral, professional character.

The type hierarchy is designed for "at-a-glance" reading in a fast-paced POS environment. Labels use a slightly increased letter spacing and uppercase styling to differentiate them from interactive body text. Large numerals (prices and quantities) should always use the `headline-lg` or `display-lg` styles to ensure they are visible from an arm's length.

## Layout & Spacing

The layout follows a **Fluid Grid** model with high-density optimization for mobile handheld devices.

- **Mobile (Vertical):** 4-column layout with 16px side margins.
- **Tablet/POS Terminal (Horizontal):** 12-column layout.
- **Ergonomics:** Key interactive elements (Order button, Payment) are pinned to the bottom 30% of the screen (the "Thumb Zone").
- **Spacing Rhythm:** All spacing is based on an 8px baseline. Use 24px or 32px of whitespace between major logical sections to maintain the "Zen" clarity and prevent the interface from feeling cluttered.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and subtle, ambient shadows.

1. **Base Layer:** Rice White (#FDFDFD) background.
2. **Surface Layer (Cards):** Pure white with a 1px hair-line stroke in a very light gray (#EDEDED) and a soft, diffused shadow (Offset 0, 4px; Blur 12px; 4% opacity black).
3. **Active/Elevated State:** When a card is selected or a modal is opened, the shadow deepens slightly to indicate focus, but should never look "heavy."

Avoid using dark shadows; the depth should feel like paper resting on a wooden table—minimal and light.

## Shapes

The shape language is defined by **Soft Geometricism**.

While the layout is rigid and structured, the corners are softened to make the technology feel more approachable and organic.

- **Cards & Modals:** 16px corner radius.
- **Buttons & Inputs:** 8px corner radius.
- **Status Tags/Chips:** Fully rounded (pill-shaped) to distinguish them from interactive buttons.
- **Line Weights:** 1.5px for icons and 1px for structural dividers.

## Components

- **Buttons:** Primary buttons use Sumie Black with Rice White text. Secondary actions use Rice White with a 1px Sumie Black border. The "Sushi Red" is reserved for the final "Confirm/Pay" action.
- **Cards:** The primary container for menu items. Must include a clear image area, item name in `body-lg`, and price in `label-lg` (Red).
- **Input Fields:** Minimalist design—bottom-border only or very light gray background. Focus state is indicated by a 1.5px Sumie Black bottom border.
- **Chips (Order Status):** Used for "Dining," "Takeout," or "Paid." These should use low-saturation background tints (e.g., Matcha Green at 10% opacity for "Paid") with high-contrast text.
- **Thin-Line Icons:** Use a consistent 1.5px stroke weight. Icons should be functional and literal (e.g., a simple outline of a sushi roll, a sharp knife for "Customization").
- **Quantity Selector:** Large, easy-to-tap +/- buttons with a minimum touch target of 48x48px to prevent errors during high-speed ordering.
