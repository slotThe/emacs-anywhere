# emacs-anywhere

This is a spin on the excellent collection of ["emacs-anywhere" shell
scripts], but stripped down to fit my needs (having all of the actual
window management done by xmonad), as well as implemented in elisp only.

To use, simply bind an instance of emacsclient to execute the function
`emacs-anywhere`.  For example, I have

    emacsclient -a '' -c -F '(quote (name . \"emacs-anywhere\"))' -e '(emacs-anywhere)'

bound as a scratchpad in my xmonad configuration.

["emacs-anywhere" shell scripts]: https://github.com/zachcurry/emacs-anywhere
