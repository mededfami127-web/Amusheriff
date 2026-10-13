#!/usr/bin/env python3
"""Merge Phase 2 (admin gateway) strings into app_en / app_am / app_ar.

Existing keys and their @-metadata are never touched; only new keys are added,
and the result is written back in the same 2-space-indented JSON style the
generator produces.
"""
import json
import os

# key: (en, am, ar)
NEW = {
    # ── Shell ────────────────────────────────────────────────────────────────
    "adminGatewayTitle": ("Admin gateway", "የአስተዳደር በር", "بوابة الإدارة"),
    "adminPreviewBadge": ("Previewing as customer", "እንደ ደንበኛ ትመልከታለች", "معاينة كزبون"),
    "adminViewStore": ("View store", "ሚስጥሩን ይመልከቱ", "عرض المتجر"),
    "adminPreviewAsCustomer": ("Preview as customer", "እንደ ደንበኛ ይመልከቱ", "معاينة كزبون"),
    "adminExitPreview": ("Exit preview", "ምልዓቱን ይውጣ", "إنهاء المعاينة"),
    "adminBackToGateway": ("Back to gateway", "ወደ በሩ ይመለሱ", "العودة إلى البوابة"),
    "adminAccount": ("Owner account", "የባለቤት መለያ", "حساب المالك"),

    # ── Dashboard ────────────────────────────────────────────────────────────
    "adminUnpublished": ("Unpublished", "ያልታወቀ", "غير منشور"),
    "adminInquiriesWeek": ("Inquiries this week", "የዚህ ሳምንት ጥያቄዎች", "استفسارات هذا الأسبوع"),
    "adminMostContacted": ("Most contacted", "በጣም የተገናኙ", "الأكثر تواصلًا"),
    "adminNoInquiriesYet": (
        "No customer taps recorded yet. They will appear here as soon as "
        "someone taps a contact button.",
        "እስካሁን የደንበኛ ጠቅላላ የለም። ማንኛውም ተጠቃሚ የመገናኛ ቁልፍ ሲጠቅም እዚህ ይታያል。",
        "لا توجد نقرات مسجلة بعد. ستظهر هنا فور نقر أحد الزوار على زر التواصل.",
    ),
    "adminQuickActions": ("Quick actions", "ፈጣን ተግባራት", "إجراءات سريعة"),
    "adminStatsProducts": ("Products", "ምርቶች", "المنتجات"),
    "adminStatsCategories": ("Categories", "ምድቦች", "الأقسام"),
    "adminViewAll": ("View all", "ሁሉንም ይመልከቱ", "عرض الكل"),

    # ── Categories ───────────────────────────────────────────────────────────
    "adminCreateCategory": ("Create category", "ምድብ ይፍጠሩ", "إنشاء قسم"),
    "adminEditCategory": ("Edit category", "ምድብ ያስተካክሉ", "تعديل القسم"),
    "adminCategoryName": ("Name (English)", "ስም (እንግሊዝኛ)", "الاسم (إنجليزي)"),
    "adminCategoryNameAm": ("Name (Amharic)", "ስም (አማርኛ)", "الاسم (أمهرية)"),
    "adminCategoryNameAr": ("Name (Arabic)", "ስም (በአረብኛ)", "الاسم (عربي)"),
    "adminSlug": ("URL slug", "የአድራሻ ቅርንጫፍ", "معرّف الرابط"),
    "adminSlugAuto": ("Generated from the English name if left empty.",
                      "ከተተወ ከእንግሊዝኛው ስም ይዘጋጃል.",
                      "يُولَّد من الاسم الإنجليزي إذا تُرك فارغًا."),
    "adminCoverImage": ("Cover image", "የመሸፈኛ ምስል", "صورة الغلاف"),
    "adminVisibleInStore": ("Visible in store", "በሚስጥሩ ይታይ", "ظاهر في المتجر"),
    "adminHide": ("Hide", "የደብቅ", "إخفاء"),
    "adminShow": ("Show", "አሳይ", "إظهار"),
    "adminDragToReorder": ("Drag to reorder", "ለመደራደር ጎትት", "اسحب لإعادة الترتيب"),
    "adminCategoryHasProducts": (
        "This category still has {count} products. Move them to another "
        "category first, or delete the products.",
        "ይህ ምድብ እስካሁን {count} ምርቶች አሉት። በመጀመሪያ ወደ ሌላ ምድብ ያስተካክሉ ወይም ምርቶቹን ይሰርዙ።",
        "لا يزال هذا القسم يحتوي على {count} منتج. انقلها إلى قسم آخر أولاً، أو احذف المنتجات.",
    ),
    "adminMoveProductsTo": ("Move products to", "ምርቶችን ወደ", "نقل المنتجات إلى"),
    "adminConfirmDeleteCategory": ("Delete this category?", "ይህን ምድብ ሊሰርዙ ነው؟", "هل تريد حذف هذا القسم؟"),
    "adminConfirmDeleteProduct": ("Delete this product?", "ይህን ምርት ሊሰርዙ ነው؟", "هل تريد حذف هذا المنتج؟"),
    "adminConfirmDeleteContact": ("Remove this link?", "ይህን አገናኝ ሊሰርዙ ነው؟", "هل تريد إزالة هذا الرابط؟"),
    "adminConfirmDeleteMessage": (
        "This cannot be undone.", "ይህን መቀስቀስ አይቻልም.", "لا يمكن التراجع عن هذا.",
    ),
    "adminNoCategories": (
        "No categories yet. Create the first one to group your products.",
        "እስካሁን ምድቦች የሉም። ምርቶችዎን ለማድረስ መጀመሪያውን ይፍጠሩ。",
        "لا توجد أقسام بعد. أنشئ أول قسم لتجميع منتجاتك.",
    ),
    "adminCategoryCreated": ("Category created", "ምድብ ተፈጥሯል", "تم إنشاء القسم"),
    "adminCategoryUpdated": ("Category updated", "ምድብ ተዘምኗል", "تم تحديث القسم"),
    "adminCategoryDeleted": ("Category deleted", "ምድብ ተሰርዟል", "تم حذف القسم"),
    "adminCategoryHidden": ("Category hidden", "ምድብ ተደብቋል", "تم إخفاء القسم"),

    # ── Products ─────────────────────────────────────────────────────────────
    "adminAddProduct": ("Add product", "ምርት ይጨምሩ", "إضافة منتج"),
    "adminEditProduct": ("Edit product", "ምርት ያስተካክሉ", "تعديل المنتج"),
    "adminSearchProducts": ("Search products", "ምርቶችን ይፈልጉ", "بحث في المنتجات"),
    "adminFilterAllCategories": ("All categories", "ሁሉም ምድቦች", "كل الأقسام"),
    "adminFilterAllStatus": ("All", "ሁሉም", "الكل"),
    "adminFilterPublished": ("Published", "ታወቀ", "منشور"),
    "adminFilterDraft": ("Draft", "ድራፍት", "مسودة"),
    "adminNoProducts": (
        "No products yet. Add your first piece to the catalogue.",
        "እስካሁን ምርቶች የለም። የመጀመሪያውን ምርት ይጨምሩ።",
        "لا توجد منتجات بعد. أضف أول قطعة إلى الكتالوج.",
    ),
    "adminNoProductsMatch": (
        "No products match your filters.",
        "ከማጣሪያዎዎ ጋር የሚገናኙ ምርቶች የሉም።",
        "لا توجد منتجات مطابقة لعوامل التصفية.",
    ),
    "adminCompareAtPrice": ("Compare-at price (optional)", "የገና ዋጋ (አማራጭ)", "السعر قبل الخصم (اختياري)"),
    "adminFeatured": ("Featured", "ተመራጭ", "مميز"),
    "adminSaveDraft": ("Save draft", "ድራፍት አስቀምጥ", "حفظ كمسودة"),
    "adminSaveAndPublish": ("Save and publish", "አስቀምጥ እና አሳትር", "حفظ ونشر"),
    "adminPublish": ("Publish", "አሳትር", "نشر"),
    "adminUnpublish": ("Unpublish", "አቁም", "إلغاء النشر"),
    "adminDuplicate": ("Duplicate", "ቀጥል", "نسخ"),
    "adminUnsavedTitle": ("Discard changes?", "ለውጦችን ይተውል?", "هل تريد تجاهل التغييرات؟"),
    "adminUnsavedMessage": (
        "You have unsaved changes. Leaving now will lose them.",
        "ያልተቀመጡ ለውጦች አሉዎ። ከአሁን ቢተዉ ይጠፋሉ。",
        "لديك تغييرات غير محفوظة. ستفقدها إذا غادرت الآن.",
    ),
    "adminDiscard": ("Discard", "አስተውል", "تجاهل"),
    "adminKeepEditing": ("Keep editing", "ቀጥል", "متابعة التحرير"),
    "adminProductSaved": ("Product saved", "ምርት ተቀምጧል", "تم حفظ المنتج"),
    "adminProductDeleted": ("Product deleted", "ምርት ተሰርዟል", "تم حذف المنتج"),
    "adminDuplicateCreated": ("Copy created", "ቅጂ ተፈጥሯል", "تم إنشاء النسخة"),
    "adminPrice": ("Price", "ዋጋ", "السعر"),
    "adminMedia": ("Media", "ሚዲያ", "الوسائط"),
    "adminAddImages": ("Add images", "ምስሎችን ይጨምሩ", "إضافة صور"),
    "adminAddVideo": ("Add video", "ቪዲዮ ይጨምሩ", "إضافة فيديو"),
    "adminUploadQueue": ("Upload queue", "የመጫን ቅርብ ጽሑፍ", "قائمة الرفع"),
    "adminUploadRetrying": ("Retrying…", "እንደገና ብትሞክሩ…", "جارٍ إعادة المحاولة…"),
    "adminRemoveMedia": ("Remove media", "ሚዲያውን አስወግድ", "إزالة الوسائط"),
    "adminSetCover": ("Set as cover", "እንደ መሸፈኛ አድርግ", "تعيين كغلاف"),
    "adminCover": ("Cover", "መሸፈኛ", "الغلاف"),
    "adminNoMedia": (
        "No images or videos yet.",
        "እስካሁን ምስሎች ወይም ቪዲዮዎች የሉም。",
        "لا توجد صور أو مقاطع فيديو بعد.",
    ),
    "adminUploadingCount": ("{done} of {total} uploaded",
                            "{total} ከ {done} ተጫኗል",
                            "{done} من {total} تم رفعها"),
    "adminSortOrderHint": ("Shown in the order below.",
                           "ከዚህ በታች በወቅቱ ይታያል.",
                           "يظهر بالترتيب أدناه."),

    # ── Contacts ─────────────────────────────────────────────────────────────
    "adminAddContact": ("Add link", "አገናኝ ይጨምሩ", "إضافة رابط"),
    "adminEditContact": ("Edit link", "አገናኝ ያስተካክሉ", "تعديل الرابط"),
    "adminContactLabel": ("Label", "መጠሪያ", "التسمية"),
    "adminContactValue": ("Value", "ዋጋ", "القيمة"),
    "adminMarkPrimary": ("Primary link", "ዋና አገናኝ", "الرابط الأساسي"),
    "adminPrimaryBadge": ("Primary", "ዋና", "أساسي"),
    "adminLivePreview": ("Customer preview", "የደንበኛ ምልዓት", "معاينة الزبون"),
    "adminNoContacts": (
        "No contact links yet. Customers reach you through these.",
        "እስካሁን የመገናኛ አገናኝ የለም። ደንበኞች ይህን በኩል ያገናኛሉ።",
        "لا توجد روابط تواصل بعد. يبلغك الزوار من خلالها.",
    ),
    "adminContactSaved": ("Link saved", "አገናኝ ተቀምጧል", "تم حفظ الرابط"),
    "adminContactDeleted": ("Link removed", "አገናኝ ተወግዷል", "تمت إزالة الرابط"),

    # ── Site settings ────────────────────────────────────────────────────────
    "adminStoreName": ("Store name", "የሚስጥር ስም", "اسم المتجر"),
    "adminStoreNameAm": ("Store name (Amharic)", "የሚስጥር ስም (አማርኛ)", "اسم المتجر (أمهرية)"),
    "adminStoreNameAr": ("Store name (Arabic)", "የሚስጥር ስም (عربي)", "اسم المتجر (عربي)"),
    "adminTagline": ("Tagline", "አፈጻጸም", "الشعار"),
    "adminAbout": ("About the store", "ስለ ሚስጥሩ", "عن المتجر"),
    "adminCurrency": ("Currency", "ምንዛሪ", "العملة"),
    "adminDefaultLanguage": ("Default language", "የመነሻ ቋንቋ", "اللغة الافتراضية"),
    "adminSiteSettingsSaved": ("Settings saved", "ቅንብሮች ተቀምጠዋል", "تم حفظ الإعدادات"),
    "adminLogoPreview": ("Logo preview", "የሎጎ ምልዓት", "معاينة الشعار"),
    "adminUploadLogo": ("Upload logo", "ሎጎ ይጫኑ", "رفع الشعار"),

    # ── Inquiries ────────────────────────────────────────────────────────────
    "adminNoInquiries": (
        "No inquiries yet. Customer taps on a contact button will show up here.",
        "እስካሁን ጥያቄዎች የለም። የደንበኛ ጠቅላላዎች እዚህ ይታያሉ።",
        "لا توجد استفسارات بعد. ستظهر هنا نقرات الزوار على أزرار التواصل.",
    ),
    "adminClearInquiries": ("Clear all", "ሁሉንም አጽዳ", "مسح الكل"),
    "adminChannel": ("Channel", "መስመር", "القناة"),
    "adminProductColumn": ("Product", "ምርت", "المنتج"),
    "adminWhen": ("When", "መቼ", "متى"),
    "adminAnonymous": ("Anonymous", "አስመስግን", "مجهول"),
    "adminInquiryDeleted": ("Inquiry cleared", "ጥያቄው ተጸድቋል", "تم حذف الاستفسار"),
    "adminJustNow": ("just now", "አሁን", "الآن"),

    # ── Security ─────────────────────────────────────────────────────────────
    "adminReauthPrompt": (
        "Enter your current password to confirm this change.",
        "ይህን ለውጥ ለማረጋገጥ የአሁኑን የይለፍ ቃል ያስገቡ።",
        "أدخل كلمة المرور الحالية لتأكيد هذا التغيير.",
    ),
    "adminStrength": ("Strength", "አጥንት", "القوة"),
    "adminStrengthWeak": ("Weak", "አትካለ", "ضعيفة"),
    "adminStrengthFair": ("Fair", "መካከለኛ", "متوسطة"),
    "adminStrengthStrong": ("Strong", "አቅም", "قوية"),
    "adminSignOutOthers": ("Sign out other sessions", "ሌሎች ክፍለ ጊዜዎችን ይውጣ", "تسجيل الخروج من الجلسات الأخرى"),
    "adminOtherSessionsSignedOut": (
        "Other sessions were signed out.",
        "ሌሎች ክፍለ ጊዜዎች ተውሰደዋል。",
        "تم تسجيل خروج الجلسات الأخرى.",
    ),

    # ── Shared actions / states ──────────────────────────────────────────────
    "actionCreate": ("Create", "ይፍጠሩ", "إنشاء"),
    "actionAdd": ("Add", "ጨምር", "إضافة"),
    "actionConfirm": ("Confirm", "አረጋግጥ", "تأكيد"),
    "actionDiscardAll": ("Discard", "አስተውል", "تجاهل"),
    "actionMove": ("Move", "አስቀይጥ", "نقل"),
    "actionSelectImage": ("Select image", "ምስል ይምረጡ", "اختر صورة"),
    "actionClear": ("Clear", "አጽዳ", "مسح"),
    "stateSaving": ("Saving…", "በመቀመጥ ላይ…", "جارٍ الحفظ…"),
    "stateSaved": ("Saved", "ተቀምጧል", "تم الحفظ"),
    "stateNoResults": ("No results", "ምንም ውጤት የለም", "لا نتائج"),
    "errorMediaUnsupportedImage": (
        "Use a JPG, PNG or WebP image.",
        "JPG, PNG ወይም WebP ምስል ይጠቀሙ。",
        "استخدم صورة JPG أو PNG أو WebP.",
    ),
    "errorMediaUnsupportedVideo": (
        "Use an MP4 video.",
        "MP4 ቪዲዮ ይጠቀሙ。",
        "استخدم فيديو MP4.",
    ),
    "errorMediaImageTooLarge": (
        "Images must be 5 MB or smaller after compression.",
        "ምስሎች ከመጨመሩ በኋላ 5 MB ወይም ከዚያ በታች መሆን አለባቸው。",
        "يجب ألا تتجاوز الصور 5 ميغابايت بعد الضغط.",
    ),
    "errorMediaVideoTooLarge": (
        "Videos must be 40 MB or smaller.",
        "ቪዲዮዎች 40 MB ወይም ከዚያ በታች መሆን አለባቸው。",
        "يجب ألا تتجاوز مقاطع الفيديو 40 ميغابايت.",
    ),
    "validateTelegramHandle": (
        "Enter a Telegram handle like @username or a t.me link",
        "የቴሌግራም አያያዝ እንደ @username ወይም t.me አገናኝ ያስገቡ",
        "أدخل معرّف تيليجرام مثل ‎@username‎ أو رابط t.me",
    ),
    "adminSectionSoon": ("Coming in the next screen", "በቀጣዩ ገጽ ይመጣል", "قادم في الشاشة التالية"),
}

OUT_DIR = os.path.join("lib", "l10n")
FILES = {
    "app_en.arb": 0,
    "app_am.arb": 1,
    "app_ar.arb": 2,
}

# CJK punctuation sometimes slips in while typing Ethiopic or Arabic copy.
# Correct it where the intent is unambiguous, then refuse to ship anything
# that still contains a CJK / Hangul / Kana code point.
CJK_PUNCT = {
    "\u3002": "\u1362",  # full stop -> Ethiopic full stop
    "\uff0c": ",",
    "\u3001": "\u1362",
    "\uff1a": ":",
    "\uff1f": "?",
    "\uff01": "!",
    "\uff1b": "\u1362",
}


# Placeholder metadata. Only the template file (app_en.arb) carries it;
# the other locales just supply the translated text.
METADATA = {
    "adminCategoryHasProducts": {
        "placeholders": {"count": {"type": "int"}},
    },
    "adminUploadingCount": {
        "placeholders": {"done": {"type": "int"}, "total": {"type": "int"}},
    },
}


def _is_forbidden(ch: str) -> bool:
    code = ord(ch)
    return (
        0x2E80 <= code <= 0x2EFF  # CJK radicals
        or 0x3000 <= code <= 0x303F  # CJK symbols and punctuation
        or 0x3040 <= code <= 0x30FF  # Kana
        or 0x3130 <= code <= 0x318F  # Hangul compatibility Jamo
        or 0x3400 <= code <= 0x4DBF  # CJK ext A
        or 0x4E00 <= code <= 0x9FFF  # CJK unified ideographs
        or 0xAC00 <= code <= 0xD7AF  # Hangul syllables
    )


def clean(key: str, value: str, index: int) -> str:
    if index == 1:  # Amharic: CJK punctuation stands in for Ethiopic marks.
        for bad, good in CJK_PUNCT.items():
            value = value.replace(bad, good)
    offenders = sorted({ch for ch in value if _is_forbidden(ch)})
    if offenders:
        raise SystemExit(
            "{} (lang index {}) contains forbidden characters: {}".format(
                key, index, ", ".join("U+%04X" % ord(c) for c in offenders)
            )
        )
    return value


def main() -> int:
    for name, index in FILES.items():
        path = os.path.join(OUT_DIR, name)
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)

        added = 0
        for key, values in NEW.items():
            if key in data:
                continue
            data[key] = clean(key, values[index], index)
            added += 1

        if index == 0:  # template: attach placeholder metadata
            for key, meta in METADATA.items():
                data["@" + key] = meta

        with open(path, "w", encoding="utf-8") as handle:
            json.dump(data, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
        print(f"{name}: +{added} keys (total {len(data)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
