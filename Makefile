# The repository is steam-dbusmenu-export; the binary, unit and package stay steam-globalmenu.
NAME := steam-globalmenu
VERSION := $(shell sed -n 's/^\#define VERSION "\(.*\)"/\1/p' src/steam-globalmenu.c)

PREFIX ?= /usr
CC ?= cc
PKG_CONFIG ?= pkg-config
LIBS := $(shell $(PKG_CONFIG) --cflags --libs dbusmenu-glib-0.4 x11 gio-unix-2.0 glib-2.0)

.PHONY: all test check install uninstall clean

all: $(NAME)

$(NAME): src/steam-globalmenu.c
	$(CC) -O2 $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) src/steam-globalmenu.c $(LIBS) -o $(NAME)

test check: $(NAME)
	VERSION=$(VERSION) ./tests/smoke.sh ./$(NAME)

install: $(NAME)
	install -Dm755 $(NAME) $(DESTDIR)$(PREFIX)/bin/$(NAME)
	install -Dm644 data/steam-globalmenu.service $(DESTDIR)$(PREFIX)/lib/systemd/user/steam-globalmenu.service
	install -Dm644 contrib/millennium/quickcss.css $(DESTDIR)$(PREFIX)/share/doc/$(NAME)/quickcss.css
	install -Dm644 LICENSE $(DESTDIR)$(PREFIX)/share/licenses/$(NAME)/LICENSE

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(NAME)
	rm -f $(DESTDIR)$(PREFIX)/lib/systemd/user/steam-globalmenu.service
	rm -rf $(DESTDIR)$(PREFIX)/share/doc/$(NAME) $(DESTDIR)$(PREFIX)/share/licenses/$(NAME)

clean:
	rm -f $(NAME)
