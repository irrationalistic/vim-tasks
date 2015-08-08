# TASKS

![example](https://raw.githubusercontent.com/irrationalistic/atom-tasks/master/images/tasks_example.png)

Special formatting for .todo and .taskpaper files. Allows you to easily add, complete, and archive your tasks.

Adjust the settings to match your ideal style. Change all the markers to '-' to match taskpaper.

Any line that ends with `:` will be considered a header (like `My Things:`)

Add tags to tasks by starting them with an `@`, such as `@important` or setting a value like `@due(tuesday)`.

This uses utf characters, so it is still valid as a plain text document.

## Installation

### Vundle
Place this in your `.vimrc`:

    Plugin 'irrationalistic/vim-tasks'

... then run the following in Vim:

    :source %
    :PluginInstall

For Vundle version < 0.10.2, replace Plugin with Bundle above.

### NeoBundle
Place this in your `.vimrc`:

    NeoBundle 'irrationalistic/vim-tasks'

... then run the following in Vim:

    :source %
    :NeoBundleInstall

### VimPlug
Place this in your `.vimrc`:

    NeoBundle 'irrationalistic/vim-tasks'

... then run the following in Vim:

    :source %
    :NeoBundleInstall

### Pathogen
Run the following in a terminal:

    cd ~/.vim/bundle
    git clone https://github.com/irrationalistic/vim-tasks

## Settings
Run `:help Tasks` to view the full documentation.

## Preset Bindings
* `<leader> n` - new task below
* `<leader> N` - new task above
* `<leader> d` - toggle current task complete
* `<leader> x` - toggle current task cancelled
* `<leader> a` - send completed tasks to the archive
