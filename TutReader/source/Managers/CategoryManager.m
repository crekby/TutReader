//
//  CategoryManager.m
//  TutReader
//
//  Created by crekby on 7/31/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CategoryManager.h"

@implementation CategoryManager

+(id)subcategoriesByCategoryID:(unsigned long)ID
{
    switch (ID) {
        case TUT:
            return [self subcategoriesForTUT];
            break;
        case AUTO:
            return [self subcategoriesForAuto];
            break;
        case IT:
            return [self subcategoriesForIT];
            break;
        case LADY:
            return [self subcategoriesForLady];
            break;
        case SPORT:
            return [self subcategoriesForSport];
            break;
        default:
            return nil;
            
    }
}

+ (unsigned long)subcategoriesCountByCategoryID:(unsigned long)ID
{
    NSArray* array = [self subcategoriesByCategoryID:ID];
    return array.count;
}

+ (id)nameForCategoryID:(unsigned long)ID
{
    switch (ID) {
        case TUT:
            return @"TUT.BY";
            break;
        case AUTO:
            return @"AUTO.TUT.BY";
            break;
        case IT:
            return @"IT.TUT.BY";
            break;
        case LADY:
            return @"LADY.TUT.BY";
            break;
        case SPORT:
            return @"SPORT.TUT.BY";
            break;
        default:
            return nil;
            
    }
}

+(id)subcategoriesForTUT
{
    return @{    // TUT.BY
             @"Все Рубрики":@"http://news.tut.by/rss/all.rss",
             @"Политика":@"http://news.tut.by/rss/politics.rss",
             @"Выборы":@"http://news.tut.by/rss/elections.rss",
             @"Экономика и бизнес":@"http://news.tut.by/rss/economics.rss",
             @"Финансы":@"http://news.tut.by/rss/finance.rss",
             @"Общество":@"http://news.tut.by/rss/society.rss",
             @"Горячая линия":@"http://news.tut.by/rss/hotline.rss",
             @"Репортер":@"http://news.tut.by/rss/reporter.rss",
             @"В мире":@"http://news.tut.by/rss/world.rss",
             @"Спорт":@"http://news.tut.by/rss/sport.rss",
             @"TUT.BY-ТВ":@"http://news.tut.by/rss/tv.rss",
             @"Культура":@"http://news.tut.by/rss/culture.rss",
             @"Леди":@"http://news.tut.by/rss/lady.rss",
             @"Наука и технологии":@"http://news.tut.by/rss/it.rss",
             @"Авто":@"http://news.tut.by/rss/auto.rss",
             @"ДТП":@"http://news.tut.by/rss/dtp.rss",
             @"Происшествия":@"http://news.tut.by/rss/accidents.rss",
             @"Калейдоскоп":@"http://news.tut.by/rss/kaleidoscope.rss",
             @"ОтКлик":@"http://news.tut.by/rss/otklik.rss",
             @"Отдых":@"http://news.tut.by/rss/summer.rss",
             @"Новости компаний":@"http://news.tut.by/rss/press.rss"
             };
}

+(id)subcategoriesForAuto
{
    return @{    // AUTO.TUT.BY
             @"Все Рубрики":@"http://news.tut.by/rss/auto/all.rss",
             @"Cadillac":@"http://news.tut.by/rss/auto/cadillac.rss",
             @"Автобизнес":@"http://news.tut.by/rss/auto/autobusiness.rss",
             @"Автоспорт":@"http://news.tut.by/rss/auto/autosport.rss",
             @"Видео":@"http://news.tut.by/rss/auto/video.rss",
             @"Дорога":@"http://news.tut.by/rss/auto/road.rss",
             @"Новинки / тест-драйвы":@"http://news.tut.by/rss/auto/test-drive.rss",
             @"Офтоп":@"http://news.tut.by/rss/auto/offtop.rss",
             @"ПДД":@"http://news.tut.by/rss/auto/pdd.rss",
             @"Проекты":@"http://news.tut.by/rss/auto/projects.rss",
             @"Происшествия":@"http://news.tut.by/rss/auto/accidents.rss",
             @"Эксклюзив":@"http://news.tut.by/rss/auto/exclusive.rss"
             };
}

+(id)subcategoriesForIT
{
    return @{    // IT.TUT.BY
             @"Все Рубрики":@"http://news.tut.by/rss/it/all.rss",
             @"В беларуси":@"http://news.tut.by/rss/it/inbelarus.rss",
             @"Гаджеты":@"http://news.tut.by/rss/it/devices_tehno.rss",
             @"Игры":@"http://news.tut.by/rss/it/videogames.rss",
             @"Интернет и связь":@"http://news.tut.by/rss/it/internet.rss",
             @"Наука":@"http://news.tut.by/rss/it/education.rss",
             @"Оружие":@"http://news.tut.by/rss/it/weapon.rss",
             @"События":@"http://news.tut.by/rss/it/events.rss"
             };
}

+(id)subcategoriesForLady
{
    return @{    // LEDY.TUT.BY
             @"Все Рубрики":@"http://news.tut.by/rss/lady/all.rss",
             @"Clever Bar":@"http://news.tut.by/rss/lady/cleverbar.rss",
             @"Анонсы":@"http://news.tut.by/rss/lady/offers.rss",
             @"Блог Ксении Беловой":@"http://news.tut.by/rss/lady/belova.rss",
             @"Блог Ольги Какшинской":@"http://news.tut.by/rss/lady/kakshinskaja.rss",
             @"Блог Саши Варламова":@"http://news.tut.by/rss/lady/varlamov.rss",
             @"Вдохновение":@"http://news.tut.by/rss/lady/inspiration.rss",
             @"Вкус Жизни":@"http://news.tut.by/rss/lady/life.rss",
             @"Делай тепло":@"http://news.tut.by/rss/lady/body.rss",
             @"Еда":@"http://news.tut.by/rss/lady/food.rss",
             @"Звезды":@"http://news.tut.by/rss/lady/stars.rss",
             @"Карьера":@"http://news.tut.by/rss/lady/work.rss",
             @"Леди Босс":@"http://news.tut.by/rss/lady/lady-boss.rss",
             @"Моя жизнь":@"http://news.tut.by/rss/lady/mylife.rss",
             @"Моя счастливая история развода":@"http://news.tut.by/rss/lady/divorce.rss",
             @"Мужчины пишут":@"http://news.tut.by/rss/lady/mensblog.rss",
             @"Наши за границей":@"http://news.tut.by/rss/lady/our-overseas.rss",
             @"От редакции":@"http://news.tut.by/rss/lady/fromeditors.rss",
             @"Отношения":@"http://news.tut.by/rss/lady/relationship.rss",
             @"Стиль":@"http://news.tut.by/rss/lady/style.rss"
             };
}

+(id)subcategoriesForSport
{
    return @{   // SPORT.TUT.BY
             @"Все Рубрики":@"http://news.tut.by/rss/sport/all.rss",
             @"Баскетбол":@"http://news.tut.by/rss/sport/basketball.rss",
             @"Биатлон":@"http://news.tut.by/rss/sport/biathlon.rss",
             @"Бокс":@"http://news.tut.by/rss/sport/box.rss",
             @"Велоспорт":@"http://news.tut.by/rss/sport/velosport.rss",
             @"Водные виды спорта":@"http://news.tut.by/rss/sport/swimming.rss",
             @"Вокруг спорта":@"http://news.tut.by/rss/sport/aboutsport.rss",
             @"Гандбол":@"http://news.tut.by/rss/sport/handball.rss",
             @"Гребля":@"http://news.tut.by/rss/sport/canoeing.rss",
             @"Единоборства":@"http://news.tut.by/rss/sport/combat.rss",
             @"Легкая атлетика":@"http://news.tut.by/rss/sport/athletics.rss",
             @"Мини-футбол":@"http://news.tut.by/rss/sport/futsal.rss",
             @"Теннис":@"http://news.tut.by/rss/sport/tennis.rss",
             @"Футбол":@"http://news.tut.by/rss/sport/football.rss",
             @"Хоккей":@"http://news.tut.by/rss/sport/hockey.rss",
             @"Шахматы и шашки":@"http://news.tut.by/rss/sport/chess.rss"
             };
}

@end
