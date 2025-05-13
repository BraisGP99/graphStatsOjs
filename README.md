# Graph Stats OJS

This plugin displays a chart via ChartJS with the monthly and yearly Stats of an OJS submission

## Instructions

### Plugin Installation Guide for OJS

You can install this plugin in two ways:

#### 1. Upload via the OJS Web Interface

-   Go to the Dashboard > Website Settings > Plugins.
-   Click on Upload a New Plugin.
-   Select the plugin .tar.gz or .zip archive and upload it.
-   Once installed, make sure to enable the plugin.

#### 2. Manual Installation

-   Upload or extract the plugin folder into the appropriate directory:
    -   ojs/plugins/generic
    -   Activate plugin from plugin from "Website -> Plugins"

#### To be considered

-   The plugin applies custom css rules that can be overwritten in the "templates/displayChart.tpl" file
-   The yearly rate by default is -5 years, which can be changed in the php file (line 96) strtotime function to declare how much traceback is required. (For example strtotime("-10 Years") would trace it back to 2015 and so on)
