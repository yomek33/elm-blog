module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { canonicalUrl = "https://elm-pages.com"
    , head = head
    }



head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.sitemapLink "/sitemap.xml"
    , Head.nonLoadingNode "link"
        [ ( "rel", Head.raw "preconnect" )
        , ( "href", Head.raw "https://fonts.googleapis.com" )
        ]
    , Head.nonLoadingNode "link"
        [ ( "rel", Head.raw "preconnect" )
        , ( "href", Head.raw "https://fonts.gstatic.com" )
        , ( "crossorigin", Head.raw "anonymous" )
        ]
    , Head.nonLoadingNode "link"
        [ ( "rel", Head.raw "stylesheet" )
        , ( "href", Head.raw "https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&display=swap" )
        ]
    ]
        |> BackendTask.succeed