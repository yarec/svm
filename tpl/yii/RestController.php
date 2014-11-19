<?php

class RestController extends Controller
{
    use PUtil\YiiUtils;

    public $layout = 'main';

	public function actions() {
		return array(
			'captcha'=>array(
				'class'=>'CCaptchaAction',
				'backColor'=>0xFFFFFF,
			),
			'page'=>array(
				'class'=>'CViewAction',
			),
		);
	}

    public function filters() {  
        return array(  
            'initdata',  
            'init',  
        );  
    }  

    public function filterInit($filterChain) {  
        $this->data['_uptm'] = date('Y-m-d H:i:s');
        self::info("initdata: " . json_encode($this->data));
        $filterChain->run();  
    }  

    /**
     * ============================
     * REST Action
     * ============================
     */

    /* GET All */
    public function actionIndex() {
        $items = $this->getItems();
        self::ret($items);
    }

    /* GET Item /{id} */
    public function actionShow($id) {
        $item= $this->loadItem($id);
        self::ret($item);
    }

    /* Post */
    public function actionCreate() {
        #$GLOBALS['HTTP_RAW_POST_DATA'];

        $this->saveItem();
    }

    /* Put Item /{id} */
    public function actionUpdate($id) {
        $this->saveItem($id);
    }

    /* Delete /{id} */
    public function actionDelete($id) {
        #Rest::model()->deleteByPk($id); 
        self::ret();
    }


    /**
     * ============================
     * DB Helper
     * ============================
     */
    public function getItems() {
        $type = isset($_GET['type'])?$_GET['type']:'all';

        $conds = '';
        $params= array();
        if($type!='all'){
            $conds = 'type=:type';
            $params = array(':type'=>$type);
        }

        $items= self::db()
            ->from('rest')  
            ->where($conds, $params)  
            ->order("id $this->order")
            ->limit($this->pagesize, $this->offset);

        $items = $items->queryAll();

        $domain = '';
        if(!empty($items)){
            foreach($items as $k=>$item){
                if(isset($item['img_name'])){
                    $items[$k]['imgurl'] = $domain.$item['img_name'];
                }
            }
        }
        $ret['data'] = $items;

        $count = Rest::model()->count($conds, $params);
        $ret = array_merge($ret, $this->getCountArray($count));

        self::ret($ret);
    }

    public function saveItem($id=null, $return=0) {
        $errs = Yii::app()->params['errors'];

        $item= $this->loadItem($id);
        if(!$item){
            $this->data['_intm'] = date('Y-m-d H:i:s');
            $item= new Rest;
        }

        $item->attributes = $this->data;
        try{
            if($item->save()){ 
                self::info("Rest save 成功: ". json_encode($item->attributes));
                if($return){
                    return $item;
                }
                else{
                    self::ret($item);
                }
            }else{ 
                $err = $item->getErrors();
                $this->error(json_encode($err));
                self::ret($err, $errs['PARAM_ERR']);
            } 
        }catch(Exception $e) {
            $msg = $e->getMessage();
            self::info("Rest save 失败: ".$msg);
            self::ret($errs['SQL_ERR']);
        }
    }

    public function loadItem($id) {
        return Rest::model()->findByPk($id);
    }
    
    /**
     * ============================
     * Buz Action
     * ============================
     */
    public function actionT() {
        self::info('');
    }
}
