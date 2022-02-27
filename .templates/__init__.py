# -*- coding: utf-8 -*-

import logging

from pkg_resources import DistributionNotFound, get_distribution

LOGGER = logging.getLogger(__name__)

__version__ = None

try:
    __version__ = get_distribution(__name__).version
except DistributionNotFound:
    # package is not installed
    pass
