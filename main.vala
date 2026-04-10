using Gtk;
using GLib;

int main (string[] args) {
    GLib.Environment.set_prgname ("year-progress");
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.bindtextdomain ("year-progress", "/usr/share/locale");
    Intl.bind_textdomain_codeset ("year-progress", "UTF-8");
    Intl.textdomain ("year-progress");

    var app = new Gtk.Application ("com.ixsvf.yearprogress", ApplicationFlags.NON_UNIQUE);
    
    app.activate.connect (() => {
        var window = new Gtk.ApplicationWindow (app);
        window.title = _("Year Progress"); 
        window.set_default_size (400, 450);

        var box = new Gtk.Box (Orientation.VERTICAL, 20);
        box.margin_start = box.margin_end = box.margin_top = box.margin_bottom = 30;
        box.halign = Align.CENTER;

        var title_label = new Gtk.Label (_("Calculating..."));
        title_label.add_css_class ("title-2");

        var overlay = new Gtk.Overlay ();
        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.set_size_request (250, 250);
        
        var center_box = new Gtk.Box (Orientation.VERTICAL, 5);
        center_box.halign = center_box.valign = Align.CENTER;

        var percent_label = new Gtk.Label ("0.0 %");
        percent_label.add_css_class ("title-2");

        var days_label = new Gtk.Label (_("Day 0 of 365"));
        days_label.add_css_class ("dim-label");

        center_box.append (percent_label);
        center_box.append (days_label);

        overlay.set_child (drawing_area);
        overlay.add_overlay (center_box);

        box.append (title_label);
        box.append (overlay);
        window.set_child (box);

        
        double target_percentage = 0.0;
        double animated_percentage = 0.0; 

        drawing_area.set_draw_func ((area, cr, width, height) => {
            double center_x = width / 2.0;
            double center_y = height / 2.0;
            double line_width = 18.0;
            double radius = double.min (width, height) / 2.0 - (line_width / 2.0);

            
            Gdk.RGBA accent_color;
            
          
            var context = area.get_style_context ();
            if (!context.lookup_color ("accent_bg_color", out accent_color)) {
             
                accent_color.parse ("#e95420");
            }

            cr.set_line_width (line_width);
            cr.set_line_cap (Cairo.LineCap.ROUND);
            
            
            cr.set_source_rgba (accent_color.red, accent_color.green, accent_color.blue, 0.2);
            cr.arc (center_x, center_y, radius, 0, 2 * Math.PI);
            cr.stroke ();

    
            cr.set_source_rgba (accent_color.red, accent_color.green, accent_color.blue, 1.0);
            
            double start_angle = -Math.PI / 2.0;
            double end_angle = start_angle + (animated_percentage * 2 * Math.PI);
            
            if (animated_percentage > 0.0001) {
                cr.arc (center_x, center_y, radius, start_angle, end_angle);
                cr.stroke ();
            }
        });

        SourceFunc update_logic = () => {
            var now = new DateTime.now_local ();
            int year = now.get_year ();
            
            var start_of_year = new DateTime.local (year, 1, 1, 0, 0, 0);
            var end_of_year = new DateTime.local (year + 1, 1, 1, 0, 0, 0);
            var last_day_of_year = new DateTime.local (year, 12, 31, 0, 0, 0);

            double diff_now = (double) now.difference (start_of_year);
            double diff_total = (double) end_of_year.difference (start_of_year);
            target_percentage = diff_now / diff_total;

      
            double step = (target_percentage - animated_percentage) * 0.05;
            
            if (step.abs() > 0.00001) {
                animated_percentage += step;
            } else {
                animated_percentage = target_percentage; // Estabiliza no valor real
            }

            int current_day = now.get_day_of_year ();
            int total_days = last_day_of_year.get_day_of_year (); 

            title_label.set_text (_("Year %d").printf(year));
            
            
            percent_label.set_text ("%.1f %%".printf(animated_percentage * 100.0));
            days_label.set_text (_("Day %d of %d").printf(current_day, total_days));

            drawing_area.queue_draw ();
            return Source.CONTINUE; 
        };

        Timeout.add (20, update_logic); // 20ms para ser mais fluido (50fps)

        window.present ();
    });

    return app.run (args);
}