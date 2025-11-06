THEMES := latte frape macchiato mocha


help:
	@echo "Utilisation :"
	@echo "		make latte		-> Applique le thème Catppuccin Latte"
	@echo "		make frape		-> Applique le thème Catppuccin Frape"
	@echo "		make macchiato	-> Applique le thème Catppuccin Macchiato"
	@echo "		make mocha		-> Applique le thème Catppuccin Mocha"


$(THEMES): dependances
	@echo "Application du thème Catppuccin-$@"
	sed -i "1s|.*|include-file = $$HOME/.config/polybar/themes/$@.ini|" "$$HOME/.config/polybar/config.ini"
	sed -i "155s|.*|(setq catppuccin-flavor '$@)|" "$$HOME/.config/emacs/README.org"
	@echo "✅ Thème '$@' appliqué avec succès !"
	@$(MAKE) move
	@$(MAKE) clear


dependances:
	@echo "Détection de la distribution Linux..."
	@if [ -f /etc/os-release ]; then \
		. /etc/os-release; \
		echo "→ Distribution détectée : $$NAME"; \
		case "$$ID" in \
			debian|ubuntu) \
				echo "Installation via apt..."; \
				sudo apt update && sudo apt install -y emacs i3 polybar rofi wget unzip ;; \
			arch|manjaro) \
				echo "Installation via pacman..."; \
				sudo pacman -Syu --noconfirm emacs i3-wm polybar rofi wget unzip ;; \
			fedora) \
				echo "Installation via dnf..."; \
				sudo dnf install -y emacs i3 polybar rofi wget unzip ;; \
			opensuse*) \
				echo "Installation via zypper..."; \
				sudo zypper install -y emacs i3 polybar rofi wget unzip ;; \
			*) \
				echo "Distribution non reconnue ($$ID). Installe manuellement emacs, i3, polybar, rofi, wget, unzip."; \
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
	cp -r ./config/* $$HOME/.config/
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
