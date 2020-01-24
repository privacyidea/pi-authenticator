#!/usr/bin/env bash

 flutter pub run intl_translation:generate_from_arb \
    --output-dir=lib/l10n --no-use-deferred-loading \
    lib/utils/localization_utils.dart lib/l10n/intl_*.arb

