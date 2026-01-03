#!/bin/bash
# Script: integrate-ssh-askpass.sh
# Purpose: Automate the addition of modern SSH askpass integration into unkpg

set -e  # exit if any command fails

echo "Starting SSH askpass integration..."

# 1️⃣ Create feature branch
git checkout -b feature/ssh-askpass
echo "Created branch feature/ssh-askpass"

# 2️⃣ Create directory structure
mkdir -p integrations/ssh/askpass/gtk/src
mkdir -p integrations/ssh/askpass/legacy-x11

echo "Directory structure created"

# 3️⃣ Create GTK main.c
cat > integrations/ssh/askpass/gtk/src/main.c <<'EOF'
#include <gtk/gtk.h>

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *dialog, *content, *label, *entry;

    dialog = gtk_dialog_new_with_buttons(
        "OpenSSH Authentication Required",
        NULL,
        GTK_DIALOG_MODAL,
        "_Cancel", GTK_RESPONSE_CANCEL,
        "_Unlock", GTK_RESPONSE_OK,
        NULL
    );

    content = gtk_dialog_get_content_area(GTK_DIALOG(dialog));

    label = gtk_label_new("Enter your SSH key passphrase:");
    gtk_label_set_xalign(GTK_LABEL(label), 0.0);

    entry = gtk_entry_new();
    gtk_entry_set_visibility(GTK_ENTRY(entry), FALSE);
    gtk_entry_set_invisible_char(GTK_ENTRY(entry), '•');
    gtk_entry_set_activates_default(GTK_ENTRY(entry), TRUE);

    gtk_box_append(GTK_BOX(content), label);
    gtk_box_append(GTK_BOX(content), entry);

    gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_OK);
    gtk_window_set_application(GTK_WINDOW(dialog), app);
    gtk_widget_show(dialog);

    if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_OK) {
        const char *pass = gtk_entry_get_text(GTK_ENTRY(entry));
        g_print("%s", pass);
    }

    gtk_window_destroy(GTK_WINDOW(dialog));
}

int main(int argc, char **argv) {
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.unkpg.askpass", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
EOF
echo "GTK main.c created"

# 4️⃣ Create GTK Makefile
cat > integrations/ssh/askpass/gtk/Makefile <<'EOF'
CC=gcc
CFLAGS=`pkg-config --cflags gtk4`
LDFLAGS=`pkg-config --libs gtk4`
TARGET=unkpg-gtk-askpass

all:
	$(CC) src/main.c -o $(TARGET) $(CFLAGS) $(LDFLAGS)

install:
	install -Dm755 $(TARGET) /usr/local/bin/$(TARGET)

clean:
	rm -f $(TARGET)
EOF
echo "GTK Makefile created"

# 5️⃣ Create GTK README
cat > integrations/ssh/askpass/gtk/README.md <<'EOF'
# GTK SSH Askpass Helper

This is the modern GTK-based SSH askpass helper for unkpg.

Build:
$ make
$ sudo make install

Security:
- Outputs passphrase only to stdout
- No logging or storage
EOF

# 6️⃣ Create selector.sh
cat > integrations/ssh/askpass/selector.sh <<'EOF'
#!/bin/sh

if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    if command -v unkpg-gtk-askpass >/dev/null 2>&1; then
        export SSH_ASKPASS=unkpg-gtk-askpass
        export SSH_ASKPASS_REQUIRE=prefer
        exit 0
    fi
fi

if command -v ssh-askpass >/dev/null 2>&1; then
    export SSH_ASKPASS=ssh-askpass
    export SSH_ASKPASS_REQUIRE=prefer
fi
EOF
chmod +x integrations/ssh/askpass/selector.sh

# 7️⃣ Create legacy X11 file (empty placeholder for now)
cat > integrations/ssh/askpass/legacy-x11/SshAskpass.ad <<'EOF'
! Legacy X11 askpass file placeholder
EOF

# 8️⃣ Create askpass README
cat > integrations/ssh/askpass/README.md <<'EOF'
# SSH Askpass Integration

Provides a GTK-based SSH passphrase helper with legacy X11 fallback.

Usage:
$ source integrations/ssh/askpass/selector.sh

Security:
- Outputs passphrase only to stdout
- No storage, logging, or network transmission
EOF

# 9️⃣ Update root README
echo -e "\n## Security Integrations\n\nunkpg includes optional, modular security integrations such as a modern SSH askpass helper. These components are disabled by default and designed to improve GUI authentication flows without altering OpenSSH behavior." >> README.md

# 10️⃣ Stage all changes
git add integrations/ssh/askpass
git add README.md

# 11️⃣ Commit
git commit -m "chore(structure): add modular ssh askpass integration layout"
git commit -m "feat(ssh): add GTK-based ssh askpass helper"
git commit -m "build(ssh): add optional GTK askpass build target"
git commit -m "feat(ssh): preserve legacy X11 ssh-askpass compatibility"
git commit -m "feat(ssh): add safe runtime askpass selector"
git commit -m "docs(ssh): document ssh askpass integration and security model"
git commit -m "docs: document optional security integrations in root README"

# 12️⃣ Merge branch into main
git checkout main
git merge feature/ssh-askpass

echo "SSH askpass integration successfully merged into main!"
