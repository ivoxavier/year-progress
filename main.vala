using Gtk;
using GLib;

int main (string[] args) {
    GLib.Environment.set_prgname ("year-progress");
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.bindtextdomain ("year-progress", "/usr/share/locale");
    Intl.bind_textdomain_codeset ("year-progress", "UTF-8");
    Intl.textdomain ("year-progress");

    var app = new Gtk.Application (null, ApplicationFlags.NON_UNIQUE);
    
    app.activate.connect (() => {
        var window = new Gtk.ApplicationWindow (app);
        window.title = _("Year Progress"); 
        window.set_default_size (400, 450);

        var box = new Gtk.Box (Orientation.VERTICAL, 20);
        box.margin_start = 30;
        box.margin_end = 30;
        box.margin_top = 30;
        box.margin_bottom = 30;
        box.halign = Align.CENTER;

        
        var title_label = new Gtk.Label (_("Calculating..."));
        title_label.add_css_class ("title-2");

        var overlay = new Gtk.Overlay ();
        
        var drawing_area = new Gtk.DrawingArea ();
        drawing_area.set_size_request (250, 250);
        
        var center_box = new Gtk.Box (Orientation.VERTICAL, 5);
        center_box.halign = Align.CENTER;
        center_box.valign = Align.CENTER;

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

        double current_percentage = 0.0;

        drawing_area.set_draw_func ((area, cr, width, height) => {
            double center_x = width / 2.0;
            double center_y = height / 2.0;
            double line_width = 18.0;
            double radius = double.min (width, height) / 2.0 - (line_width / 2.0);

            cr.set_line_width (line_width);
            cr.set_line_cap (Cairo.LineCap.ROUND);
            cr.set_source_rgba (0.5, 0.5, 0.5, 0.2);
            cr.arc (center_x, center_y, radius, 0, 2 * Math.PI);
            cr.stroke ();

            cr.set_source_rgb (0.91, 0.33, 0.13);
            double start_angle = -Math.PI / 2.0;
            double end_angle = start_angle + (current_percentage * 2 * Math.PI);
            
            if (current_percentage > 0) {
                cr.arc (center_x, center_y, radius, start_angle, end_angle);
                cr.stroke ();
            }
        });

        SourceFunc update_progress = () => {
            var now = new DateTime.now_local ();
            int year = now.get_year ();
            
            var start_of_year = new DateTime.local (year, 1, 1, 0, 0, 0);
            var end_of_year = new DateTime.local (year + 1, 1, 1, 0, 0, 0);
            var last_day_of_year = new DateTime.local (year, 12, 31, 0, 0, 0);

            double diff_now = (double) now.difference (start_of_year);
            double diff_total = (double) end_of_year.difference (start_of_year);
            current_percentage = diff_now / diff_total;

            int current_day = now.get_day_of_year ();
            int total_days = last_day_of_year.get_day_of_year (); 

            
            title_label.set_text (_("Year %d").printf(year));
            percent_label.set_text ("%.1f %%".printf(current_percentage * 100.0));
            days_label.set_text (_("Day %d of %d").printf(current_day, total_days));

            drawing_area.queue_draw ();

            return Source.CONTINUE; 
        };

        update_progress ();
        Timeout.add (50, update_progress);

        window.present ();
    });

    return app.run (args);
}