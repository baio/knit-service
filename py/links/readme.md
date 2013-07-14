    *order by names name_1 < name_2*

    user
    {
        _id : "user_name"

        contribs : [

            ref : [ user : "ref_user_name", contrib : "ref_contrib_name" ] // or

            name : "contrib_name"

            date : contrib_date

            data :
            [
                name_1 : "name 1"

                name_2 : "name 2"

                url : "url to source"

                tags : [ "tag" ]

                src_ref : "from where cloned"
            ]
        ]

        graphs : [

            name : ""

            nodes : [

                _id : "lname_fname"

                pos : [x, y]
            ]

            edges : [

                _id : "lname1_fname1_lname2_fname2"

                tags : [ tag : "type", urls : [ "url" ] ]
            ]

            fs_ref : "ref to fs collection with gexf file"
        ]
    }