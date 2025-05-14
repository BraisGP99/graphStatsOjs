<?php

/**
 * @file plugins/blocks/journalMetrics/JournalMetricsPlugin.php
 *
 * Copyright (c) 2014-2024 Simon Fraser University
 * Copyright (c) 2003-2024 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class JournalMetricsSettingsForm
 * @ingroup plugins_blocks_journalMetrics
 *
 * @brief Form for journal managers to modify journal Metrics plugin settings
 */

 namespace APP\plugins\generic\graphStatsOjs\classes\Settings;
 
 use APP\core\Application;
 use APP\notification\Notification;
 use APP\notification\NotificationManager;
 use APP\template\TemplateManager;
 use PKP\form\Form;
 use APP\plugins\generic\graphStatsOjs\classes\Constants;
 use APP\plugins\generic\graphStatsOjs\GraphStatsOjsPlugin;
 use PKP\form\validation\FormValidatorCSRF;
 use PKP\form\validation\FormValidatorPost;

class GraphStatsOjsSettingsForm extends Form {

    /** @var GraphStatsOjsPlugin */
    public GraphStatsOjsPlugin $plugin;

    /**
     * Defines the settings form's template and adds validation checks.
     *
     * Always add POST and CSRF validation to secure your form.
     */
    public function __construct(GraphStatsOjsPlugin &$plugin)
    {
        $this->plugin = &$plugin;

        parent::__construct($this->plugin->getTemplateResource(Constants::SETTINGS_TEMPLATE));

        $this->addCheck(new FormValidatorPost($this));
        $this->addCheck(new FormValidatorCSRF($this));
    }

    /**
     * Load settings already saved in the database
     *
     * Settings are stored by context, so that each journal, press,
     * or preprint server can have different settings.
     */
    public function initData(): void
    {
        $context = Application::get()
            ->getRequest()
            ->getContext();

        $this->setData(
            Constants::FROM_YEAR,
            $this->plugin->getSetting(
                $context->getId(),
                Constants::FROM_YEAR
            )
        );
        parent::initData();
    }

    /**
     * Load data that was submitted with the form
     * 
     * 
     */
    public function readInputData(): void
    {
        $this->readUserVars([Constants::FROM_YEAR]);

        parent::readInputData();
    }

    /**
     * Fetch any additional data needed for your form.
     *
     * Data assigned to the form using $this->setData() during the initData() or readInputData() methods will be passed to the template.
     *
     * In the example below, the plugin name is passed to the
     * template so that it can be used in the URL that the form is
     * submitted to.
     */
    public function fetch($request, $template = null, $display = false): ?string
    {
        
        $templateMgr = TemplateManager::getManager($request);
        $templateMgr->assign('pluginName', $this->plugin->getName());

        return parent::fetch($request, $template, $display);
    }

    /**
     * Save the plugin settings and notify the user
     * that the save was successful
     */
    public function execute(...$functionArgs): mixed
    {
        $context = Application::get()
            ->getRequest()
            ->getContext();

            $fromYear = $this->getData(Constants::FROM_YEAR);

        $this->plugin->updateSetting(
            $context->getId(),
            Constants::FROM_YEAR,
            $fromYear
        );
        $notificationMgr = new NotificationManager();
        $notificationMgr->createTrivialNotification(
            Application::get()->getRequest()->getUser()->getId(),
            Notification::NOTIFICATION_TYPE_SUCCESS,
            ['contents' => __('common.changesSaved')]
        );

        return parent::execute();
    }

   
}