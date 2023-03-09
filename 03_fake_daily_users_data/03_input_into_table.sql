INSERT INTO `bq_nested_repeated_fields_demo.daily_users`
VALUES (
    DATE('2022-03-07'),
    '1234567890123456',
    'Mobile',
    STRUCT('Chrome', '97.0.4692.99'),
    STRUCT('Android', '11'),
    STRUCT('tablet', 'Samsung', 'Galaxy Tab S6 Lite'),
    false,
    '1.2.3',
    'portrait',
    ['portrait', 'landscape'],
    'United States',
    struct("North America", "United States", "California", "Los Angeles", "LA", ["United States"]),
    STRUCT(false, false, true, DATE('2022-03-01')),
    STRUCT(2, 1, 4, 180),
    [
        STRUCT(
            'Football',
            STRUCT(5, 3, 10, 1200),
            [
                STRUCT(
                    'Premier League',
                    STRUCT(3, 2, 5, 500),
                    [
                        STRUCT(
                            'England',
                            'Manchester United',
                            'Arsenal',
                            STRUCT(2, 1, 3, 300),
                            [
                                STRUCT(
                                    'match started',
                                    STRUCT(1, 1, 2, 200),
                                    [
                                        STRUCT(
                                            'score',
                                            STRUCT(1, 1, 2, 200)
                                        ),
                                        STRUCT(
                                            'lineups',
                                            STRUCT(0, 0, 0, 0)
                                        )
                                    ]
                                ),
                                STRUCT(
                                    'match ended',
                                    STRUCT(1, 0, 1, 100),
                                    [
                                        STRUCT(
                                            'scorers',
                                            STRUCT(1, 0, 1, 100)
                                        )
                                    ]
                                )
                            ]
                        ),
                        STRUCT(
                            'Spain',
                            'Barcelona',
                            'Real Madrid',
                            STRUCT(1, 1, 2, 200),
                            [
                                STRUCT(
                                    'match started',
                                    STRUCT(0, 0, 0, 0),
                                    [
                                        STRUCT(
                                            'score',
                                            STRUCT(0, 0, 0, 0)
                                        ),
                                        STRUCT(
                                            'lineups',
                                            STRUCT(0, 0, 0, 0)
                                        )
                                    ]
                                ),
                                STRUCT(
                                    'match ended',
                                    STRUCT(1, 0, 1, 100),
                                    [
                                        STRUCT(
                                            'scorers',
                                            STRUCT(1, 0, 1, 100)
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                STRUCT(
                    'Champions League',
                    STRUCT(2, 1, 5, 500),
                    [
                        STRUCT(
                            'Italy',
                            'Milan',
                            'Inter',
                            STRUCT(1, 1, 2, 200),
                            [
                                STRUCT(
                                    'match started',
                                    STRUCT(1, 1, 2, 200),
                                    [
                                        STRUCT(
                                            'score',
                                            STRUCT(1, 1, 2, 200)
                                        ),
                                        STRUCT(
                                            'lineups',
                                            STRUCT(0, 0, 0, 0)
                                        )
                                    ]
                                ),
                                STRUCT(
                                    'match ended',
                                    STRUCT(0, 0, 0, 0),
                                    [
                                        STRUCT(
                                            'scorers',
                                            STRUCT(0, 0, 0, 0)
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    ]
