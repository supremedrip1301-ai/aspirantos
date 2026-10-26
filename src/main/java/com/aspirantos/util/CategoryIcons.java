package com.aspirantos.util;

import java.util.HashMap;
import java.util.Map;

/**
 * Small line icons for the exam categories (exam_category.icon_svg_name), drawn by hand as
 * SVG paths on a 24 x 24 grid - no icon library, no internet needed. The stroke uses
 * currentColor, so the icon takes the text colour of the tile (light and dark theme).
 */
public class CategoryIcons {

    private static final Map<String, String> PATHS = new HashMap<>();

    static {
        PATHS.put("landmark", "M3 21h18M5 21V10M9 21V10M15 21V10M19 21V10M2 10l10-6 10 6");
        PATHS.put("pen", "M4 20l4-1 11-11-3-3L5 16l-1 4zM14 6l3 3");
        PATHS.put("bank", "M3 21h18M4 10h16M12 3l9 5H3zM6 10v8M10 10v8M14 10v8M18 10v8");
        PATHS.put("umbrella", "M12 3a9 9 0 0 1 9 9H3a9 9 0 0 1 9-9zM12 12v7a2 2 0 0 1-4 0");
        PATHS.put("train", "M7 3h10a3 3 0 0 1 3 3v8a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3zM4 10h16M8 21l2-4M16 21l-2-4M8 13.5h.01M16 13.5h.01");
        PATHS.put("shield", "M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6l8-3z");
        PATHS.put("badge", "M12 2l3 6 6 1-4.5 4 1 6-5.5-3-5.5 3 1-6L3 9l6-1z");
        PATHS.put("map", "M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2zM9 4v14M15 6v14");
        PATHS.put("building", "M4 21V5l8-2v18M12 7l8 2v12M7 9h2M7 13h2M7 17h2M15 12h2M15 16h2M2 21h20");
        PATHS.put("book", "M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2V5zM4 19a2 2 0 0 1 2-2h13");
        PATHS.put("scale", "M12 3v18M7 21h10M5 7h14M5 7l-3 6a3 3 0 0 0 6 0L5 7zM19 7l-3 6a3 3 0 0 0 6 0l-3-6z");
        PATHS.put("gear", "M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6zM12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9L7 7M17 17l2.1 2.1M4.9 19.1L7 17M17 7l2.1-2.1");
        PATHS.put("cog", "M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM12 3v2M12 19v2M3 12h2M19 12h2M6 6l1.5 1.5M16.5 16.5L18 18M6 18l1.5-1.5M16.5 7.5L18 6");
        PATHS.put("stethoscope", "M6 3v6a4 4 0 0 0 8 0V3M10 13v3a5 5 0 0 0 10 0v-2M20 10a2 2 0 1 0 0 4 2 2 0 0 0 0-4z");
        PATHS.put("heart", "M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z");
        PATHS.put("flask", "M9 3h6M10 3v6L4 19a1 1 0 0 0 1 2h14a1 1 0 0 0 1-2l-6-10V3M7 15h10");
        PATHS.put("briefcase", "M3 8h18v12H3zM8 8V5h8v3M3 13h18");
        PATHS.put("compass", "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM15.5 8.5l-2 5-5 2 2-5z");
        PATHS.put("atom", "M12 11a1 1 0 1 0 0 2 1 1 0 0 0 0-2zM12 3c3 0 5 4 5 9s-2 9-5 9-5-4-5-9 2-9 5-9zM3 12c0-3 4-5 9-5s9 2 9 5-4 5-9 5-9-2-9-5z");
        PATHS.put("leaf", "M5 19C5 9 11 4 20 4c0 9-5 15-15 15zM5 19l8-8");
        PATHS.put("calculator", "M6 3h12v18H6zM9 7h6M9 12h.01M12 12h.01M15 12h.01M9 16h.01M12 16h.01M15 16h.01");
        PATHS.put("university", "M2 9l10-5 10 5-10 5-10-5zM6 11v5c3 2 9 2 12 0v-5M22 9v6");
        PATHS.put("school", "M3 21h18M5 21V9l7-5 7 5v12M10 21v-5h4v5");
        PATHS.put("chef", "M6 13a4 4 0 0 1 1-8 5 5 0 0 1 10 0 4 4 0 0 1 1 8v6H6v-6zM6 17h12");
        PATHS.put("globe", "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18");
        // navigation icons (sidebar, bottom bar, top header) - same 24 x 24 grid
        PATHS.put("nav-home", "M3 11l9-7 9 7M5 9.5V20h5v-6h4v6h5V9.5");
        PATHS.put("nav-explore", "M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM16 16l5 5");
        PATHS.put("nav-horizon", "M3 20h18M5 16h9M5 12h13M5 8h6M5 4v16");
        PATHS.put("nav-calendar", "M4 6h16v15H4zM4 10h16M8 3v5M16 3v5M8 14h2M14 14h2M8 17h2");
        PATHS.put("nav-journal", "M6 3h12v18H6zM9 7h6M9 11h6M9 15h3M4 7h2M4 12h2M4 17h2");
        PATHS.put("nav-profile", "M12 4a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM4 21c1-4 4-6 8-6s7 2 8 6");
        PATHS.put("nav-bell", "M6 17V11a6 6 0 0 1 12 0v6l2 2H4zM10 21h4");
        PATHS.put("nav-settings", "M4 7h10M18 7h2M4 17h4M12 17h8M16 5v4M10 15v4");
        PATHS.put("nav-users", "M9 4a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7zM2.5 20c.8-3.5 3.3-5.5 6.5-5.5s5.7 2 6.5 5.5M16 4.5a3.3 3.3 0 0 1 0 6.3M18 14.8c1.8.7 3 2.5 3.5 5.2");
        PATHS.put("nav-flag", "M5 21V4M5 4h11l-2 4 2 4H5");
        PATHS.put("nav-list", "M8 6h13M8 12h13M8 18h13M3.5 6h.01M3.5 12h.01M3.5 18h.01");
        PATHS.put("nav-package", "M12 3l8 4v10l-8 4-8-4V7zM4 7l8 4 8-4M12 11v10");
        PATHS.put("nav-refresh", "M20 11a8 8 0 0 0-14.5-4.5L4 8M4 4v4h4M4 13a8 8 0 0 0 14.5 4.5L20 16M20 20v-4h-4");
        PATHS.put("nav-database", "M12 3c4.4 0 8 1.3 8 3s-3.6 3-8 3-8-1.3-8-3 3.6-3 8-3zM4 6v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3");
        PATHS.put("nav-logout", "M14 4h5v16h-5M10 8l-4 4 4 4M6 12h10");
        PATHS.put("nav-info", "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 11v6M12 7.5h.01");
    }

    /** The inline SVG of an icon (a circle when the name is unknown). */
    public static String svg(String name) {
        return svg(name, "cat-icon", 28);
    }

    /** The inline SVG of an icon with its own CSS class and size (navigation icons). */
    public static String svg(String name, String cssClass, int size) {
        String d = PATHS.get(name);
        if (d == null) {
            d = "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18z";
        }
        return "<svg class=\"" + cssClass + "\" viewBox=\"0 0 24 24\" width=\"" + size + "\" height=\"" + size + "\" aria-hidden=\"true\" focusable=\"false\">"
                + "<path d=\"" + d + "\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.7\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></svg>";
    }
}
