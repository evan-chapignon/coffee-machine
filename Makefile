THEMES := latte frape macchiato mocha

SERVICE_NAME ?= emacs
SYSTEMD_USER_DIR := $(HOME)/.config/systemd/user
SERVICE_FILE := $(SYSTEMD_USER_DIR)/$(SERVICE_NAME).service


help:
	@echo "Utilisation :"
	@echo "		make latte		-> Applique le thème Catppuccin Latte"
	@echo "		make frape		-> Applique le thème Catppuccin Frape"
	@echo "		make macchiato	        -> Applique le thème Catppuccin Macchiato"
	@echo "		make mocha		-> Applique le thème Catppuccin Mocha"


$(THEMES): dependances
	@echo "Application du thème Catppuccin-$@"
	sed -i "1s|.*|include-file = ./.config/polybar/themes/$@.ini|" "./.config/polybar/config.ini"
	sed -i "11s|.*|(setq catppuccin-flavor '$@)|" "./.config/emacs/theme.org"
	sed -i "19s|.*|exec_always --no-startup-id feh --bg-scale ~/.config/i3/fde/$@.png|" "./.config/i3/config"
	@mkdir -p ~/.config/alacritty
	@echo 'general.import = ["~/.config/alacritty/catppuccin-$@.toml"]' > ~/.config/alacritty/alacritty.toml
	wget -q -O ~/.config/alacritty https://github.com/catppuccin/alacritty/raw/main/catppuccin-$@.toml || true
	@echo "✅ Thème '$@' appliqué avec succès !"
	@$(MAKE) move
	@$(MAKE) emacsserv
	@$(MAKE) clear
	@echo -e "\e[33mNous vous invitons à vous déconnecter pour lancer i3.\e[0m"

emacsserv:
	@echo "==> Création du dossier systemd user si nécessaire..."
	@mkdir -p $(SYSTEMD_USER_DIR)

	@echo "==> Suppression de l'ancien service si existant..."
	@if systemctl --user is-active --quiet $(SERVICE_NAME).service; then \
		systemctl --user stop $(SERVICE_NAME).service; \
	fi
	@if systemctl --user list-unit-files | grep -q "^$(SERVICE_NAME).service"; then \
		systemctl --user disable $(SERVICE_NAME).service; \
		rm -f $(SERVICE_FILE); \
	fi

	@echo "Copie du nouveau fichier de service systemd..."
	@cp ./systemd/user/emacs.service $(SERVICE_FILE)

	@echo "Rechargement des unités systemd user..."
	@systemctl --user daemon-reload

	@echo "==> Activation et démarrage du service Emacs..."
	@systemctl --user enable $(SERVICE_NAME).service
	@systemctl --user start $(SERVICE_NAME).service

	@echo "Création du dossier serveur Emacs si nécessaire..."
	@mkdir -p $(HOME)/.config/emacs/server

	@echo "Vérification du statut du serveur Emacs..."
	@systemctl --user status $(SERVICE_NAME).service --no-pager


dependances:
	@echo "Détection de la distribution Linux..."
	@if [ -f /etc/os-release ]; then \
		. /etc/os-release; \
		echo "→ Distribution détectée : $$NAME"; \
		case "$$ID" in \
			debian|ubuntu) \
				echo "Installation via apt..."; \
				sudo apt update && sudo apt install -y emacs i3 polybar rofi wget unzip feh fonts-jetbrains-mono ;; \
			arch|manjaro) \
				echo "Installation via pacman..."; \
				sudo pacman -Syu --noconfirm emacs i3-wm polybar rofi wget feh unzip ttf-jetbrains-mono ;; \
			fedora) \
				echo "Installation via dnf..."; \
				sudo dnf install -y emacs i3 polybar rofi wget unzip feh jetbrains-mono-fonts ;; \
			opensuse*) \
				echo "Installation via zypper..."; \
				sudo zypper install -y emacs i3 polybar rofi wget unzip feh jetbrains-mono-fonts ;; \
			*) \
				echo "Distribution non reconnue ($$ID). Installe manuellement emacs, i3, polybar, rofi, wget, unzip, feh, jetbrain-mono-fonts."; \
				exit 1 ;; \
		esac; \
	else \
		echo "Fichier /etc/os-release introuvable. Impossible de détecter la distribution."; \
		exit 1; \
	fi
	@echo "Téléchargement et installation de la police Iosevka Nerd Font..."
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Iosevka.zip -O /tmp/Iosevka.zip
	mkdir -p $$HOME/.local/share/fonts
	unzip -o /tmp/Iosevka.zip -d $$HOME/.local/share/fonts/
	fc-cache -fv
	@echo "Installation terminée."


move:
	@echo "Déplacement des fichiers de ./config vers $$HOME/.config..."
	mkdir -p $$HOME/.config
	cp -r ./.config/* $$HOME/.config/
	@echo "Tous les fichiers ont été copiés dans $$HOME/.config"


clear:
	@echo "ATTENTION : Cette commande va SUPPRIMER LE DOSSIER COURANT ET TOUT SON CONTENU !"
	@read -p "Es-tu sûr de vouloir continuer ? (oui/non) " rep; \
	if [ "$$rep" = "oui" ]; then \
		parent=$$(dirname "$$PWD"); \
		current=$$(basename "$$PWD"); \
		cd "$$parent"; \
		rm -rf "$$current"; \
		echo "Le dossier '$$current' a été supprimé."; \
	else \
		echo "Suppression annulée."; \
	fi
	@echo "Installation terminée"
	@echo "Bienvenue dans le doux monde de la coffee-machine"
