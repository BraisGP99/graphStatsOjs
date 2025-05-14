{**
    * templates/settings.tpl
    *
    * Copyright (c) 2014-2023 Simon Fraser University
    * Copyright (c) 2003-2023 John Willinsky
    * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
    *
    * Settings form for the graphStatsOjs plugin.
    *}
<script>
    $(function() {
        $('#graphStatsOjsSettings').pkpHandler('$.pkp.controllers.form.AjaxFormHandler');
    });
</script>

<form
    class="pkp_form"
    id="graphStatsOjsSettings"
    method="POST"
    action="{url router=$smarty.const.ROUTE_COMPONENT op="manage" category="generic" plugin=$pluginName verb="settings" save=true}"
>
    {csrf}

    {fbvFormSection label="plugins.block.graphStatsOjs.fromYear.description"}
        {fbvElement
            type="text"
            id="fromYear"
            name="fromYear"
            value=$fromYear
            description="plugins.block.graphStatsOjs.fromYear.description"
            size="short"
        }
    {/fbvFormSection}

    {fbvFormButtons submitText="common.save"}
</form>
