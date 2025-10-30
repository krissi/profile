if [ -n "$HOME" ]; then
	if [ "$BASH" ]; then
	  if [ -f "$HOME/.bashrc" ]; then
	    . "$HOME/.bashrc"
	  fi
	fi

	if [ -d "$HOME/bin" ]; then
		PATH+=":$HOME/bin"
	fi
	if [ -d "$HOME/.local/bin" ]; then
		PATH+=":$HOME/.local/bin"
	fi
fi
