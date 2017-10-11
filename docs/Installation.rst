============
Installation
============

Installation does not need anything special at all. Download source files from github and put it into an arbitary directory.

.. code-block:: bash

   $ cd /path/to/a_directory
   $ git clone https://github.com/moritoru81/baut

Set the path to ``baut`` script to ``PATH``.

.. code-block:: bash

   $ cat <<EOS >> ~/.bash_profile
   export PATH="$(pwd)/baut/bin:\$PATH"
   EOS
   $ source ~/.bash_profile

You can also run ``install.sh`` to do it.

.. code-block:: bash

   $ source baut/install.sh

Run ``baut`` for confirmation of installation, then you will see the usage of Baut.

.. code-block:: bash

   $ baut help
