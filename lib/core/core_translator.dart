import 'lang/constance_child/constant_child_lang.dart';
import 'lang/constance_course/constant_course_lang.dart';
import 'lang/constance_parent/constant_parent_lang.dart';
import 'lang/constance_payment/constant_payment_lang.dart';
import 'lang/constance_presentation/constant_presentation_lang.dart';
import 'lang/constance_session/constant_session_lang.dart';
import 'lang/constance_statistics/constant_statistics_lang.dart';
import 'lang/constances/constant_lang.dart';

class Translator {
  String translatorFile = '';
  Map<String, String> defaultLang = Map();
  Map<String, String> currLang = Map();
  
  Translator({StatusLangue status = StatusLangue.CONSTANCE_CHILD, String lang = ''}) {
    
    if(lang=='')return;

    switch (status) {
      case StatusLangue.CONSTANCE_CHILD:
        defaultLang = ConstantChildLangue.getDefault();
        currLang = ConstantChildLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_COURSE:
        defaultLang = ConstantCourseLangue.getDefault();
        currLang = ConstantCourseLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_PARENT:
        defaultLang = ConstantParentLangue.getDefault();
        currLang = ConstantParentLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_PAYMENT:
        defaultLang = ConstantPaymentLangue.getDefault();
        currLang = ConstantPaymentLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_PRESENTATION:
        defaultLang = ConstantPresentationLangue.getDefault();
        currLang = ConstantPresentationLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_SESSION:
        defaultLang = ConstantSessionLangue.getDefault();
        currLang = ConstantSessionLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_STATISTICS:
        defaultLang = ConstantStatisticsLangue.getDefault();
        currLang = ConstantStatisticsLangue.getDictionnary(lang);
        break;

      case StatusLangue.CONSTANCE_CONSTANCE:
        defaultLang = ConstantConstantLangue.getDefault();
        currLang = ConstantConstantLangue.getDictionnary(lang);
        break;
    }
  }

  String getText(String key) {
    //print('00000033333333wwwwwwwwwwwwww====== '+ key +' ======wwwwwwwwwww333333333000000');
    return currLang.containsKey(key) ? currLang[key]??'' : defaultLang[key]??'';
  }

}

enum StatusLangue {
  CONSTANCE_CHILD,
  CONSTANCE_COURSE,
  CONSTANCE_PARENT,
  CONSTANCE_PAYMENT,
  CONSTANCE_PRESENTATION,
  CONSTANCE_SESSION,
  CONSTANCE_STATISTICS,
  CONSTANCE_CONSTANCE,
}
