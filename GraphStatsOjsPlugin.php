<?php
/**
 * @file graphStatsOjsPlugin.php
 *
 * Copyright (c) 2017-2023 Simon Fraser University
 * Copyright (c) 2017-2023 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class graphStatsOjsPlugin
 * @brief Plugin class for the graphStatsOjs plugin.
 */

namespace APP\plugins\generic\graphStatsOjs;

use PKP\plugins\GenericPlugin;
use PKP\plugins\Hook;
use APP\core\Application;
use APP\template\TemplateManager;
use APP\facades\Repo;
use APP\core\Services;
use PKP\core\JSONMessage;
use APP\plugins\generic\graphStatsOjs\classes\Settings\Actions;
use APP\plugins\generic\graphStatsOjs\classes\Settings\Manage;
use APP\core\Request;
use APP\plugins\generic\graphStatsOjs\classes\Constants;
use PKP\author\DAO as AuthorDAO;


class GraphStatsOjsPlugin extends GenericPlugin
{
    /** @copydoc GenericPlugin::register() */
    public function register($category, $path, $mainContextId = null): bool
    {
        $success = parent::register($category, $path);

        if ($success && $this->getEnabled()) {
          Hook::add('Templates::Article::Main',[$this,'getData']);
        }

        return $success;
    }

    /**
     * Provide a name for this plugin
     *
     * The name will appear in the Plugin Gallery where editors can
     * install, enable and disable plugins.
     */
    public function getDisplayName(): string
    {
        return __('plugins.generic.graphStatsOjs.displayName');
    }

    /**
     * Provide a description for this plugin
     *
     * The description will appear in the Plugin Gallery where editors can
     * install, enable and disable plugins.
     */
    public function getDescription(): string
    {
        return __('plugins.generic.graphStatsOjs.description');
    }

    public function getData($hookName,$args){
        $request = Application::get()->getRequest();
        $templateMgr = TemplateManager::getManager($request);
        $router = $request->getRouter();
        $requestedArgs = $router->getRequestedArgs($request);
        $templateMgr->addJavaScript(
            'chartjs', 
            'https://cdn.jsdelivr.net/npm/chart.js',
            ['contexts' => ['frontend']]);

        $submissionId = $requestedArgs[0] ?? null;
        $submission = is_numeric($submissionId)? Repo::submission()->get(intval($submissionId)) :null;
        if($submission !== null){
            $stats =  $this->getStatistics($submissionId);
            $templateMgr->assign('stats',$stats);
          

        }
        $templateMgr->display($this->getTemplateResource('displayChart.tpl'),true);

        return false;
    }

    
    private function getStatistics($submissionId){
        $request = Application::get()->getRequest();
        $context = $request->getContext();
        $statsService = Services::get('publicationStats');
        $year = date('Y');
        $stats = [];
        $stats['editorial'] = $this->getStatsEditorial();
        $stats['month'] = $this->getStatsMonth($submissionId);
        $stats['year'] = $this->getStatsYear($submissionId);
        $stats['authors'] = $this->getAuthors($submissionId);
        
        return json_encode($stats);
    }
    
    private function getStatsEditorial(){
        $request = Application::get()->getRequest();
        $context = $request->getContext();
        $statisticsHelper = Services::get('editorialStats');

        $contextId = $context->getId();

        $filters = [ 'contextIds'=>[$contextId],'assocTypes'=>[ASSOC_TYPE_SUBMISSION]];

        $metrics = $statisticsHelper->getOverview($filters);

        // var_export($metrics);

        return $metrics;
    }


    private function getStatsMonth($submissionId){
        $request = Application::get()->getRequest();
        $context = $request->getContext();
        $statsService = Services::get('publicationStats');
        $year = date('Y');
        $statsMonth = [];

        for($i = 1; $i<=12;$i++){
            $startDate = sprintf('%s-%02d-01', $year, $i);
            $endDate = date('Y-m-t', strtotime($startDate));
            
            $totalMonth = $statsService->getTotalsByType($submissionId,$context->getId(),$startDate,$endDate);
            $totalMonth['month'] = $i;
            $statsMonth[$i] = $totalMonth;
        }
        return $statsMonth;
    }

    private function getStatsYear($submissionId){
        $request = Application::get()->getRequest();
        $context = $request->getContext();
        $statsService = Services::get('publicationStats');
        $year = date('Y');
        $statsYear = [];
        $fromYear =(int)$this->getSetting($context->getId(), Constants::FROM_YEAR);
        echo $fromYear;
        $year = date('Y') - $fromYear;
        for($i = 0;$i<=$fromYear;$i++){
            $currentYear = $year + $i;
            $totalYear = $statsService->getTotalsByType($submissionId,$context->getId(),"$currentYear-01-01","$currentYear-12-31");
            $totalYear['year'] = $currentYear;
            $statsYear[$i] = $totalYear;
        }
        
        return $statsYear;
    }

    private function getAuthors(){
        $request = Application::get()->getRequest();
        $context = $request->getContext();
    
        $submissions = Repo::submission()
            ->getCollector()
            ->filterByContextIds([$context->getId()])
            ->filterByStatus([\APP\submission\Submission::STATUS_PUBLISHED])
            ->getMany();
    
        $authors = [];
    
        foreach ($submissions as $submission) {
            $authorsRepo = Repo::author()
                ->getCollector()
                ->getMany();
    
            foreach ($authorsRepo as $author) {
                if (!in_array($author, $authors)) {
                    $authors[] = $author;
                }
            }
        }
        return $authors;
    }


    /**
     * Add a settings action to the plugin's entry in the plugins list.
     *
     * @param Request $request
     * @param array $actionArgs
     */
    public function getActions($request, $actionArgs): array
    {
        $actions = new Actions($this);
        
        

        return $actions->execute($request, $actionArgs, parent::getActions($request, $actionArgs));
    }

    /**
     * Load a form when the `settings` button is clicked and
     * save the form when the user saves it.
     *
     * @param array $args
     * @param Request $request
     */
    public function manage($args, $request): JSONMessage
    {
        $manage = new Manage($this);
      
        return $manage->execute($args, $request);
    }

}