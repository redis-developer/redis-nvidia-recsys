
import datetime

from google.protobuf.duration_pb2 import Duration
from feast import Entity, Feature, FeatureView, ValueType
from feast.infra.offline_stores.file_source import FileSource

item_features = FileSource(
    path=/workdir/feature_repo/feature_repo/data/item_features.parquet,
    event_timestamp_column="datetime",
    created_timestamp_column="created",
)

item = Entity(name="item_id", value_type=ValueType.INT32, description="item id",)

item_features_view = FeatureView(
    name="item_features",
    entities=["item_id"],
    ttl=Duration(seconds=86400 * 7),
    features=[
        Feature(name="item_category", dtype=ValueType.INT32),
        Feature(name="item_shop", dtype=ValueType.INT32),
        Feature(name="item_brand", dtype=ValueType.INT32),
        Feature(name="item_id_raw", dtype=ValueType.INT32),
    ],
    online=True,
    input=item_features,
    tags=dict(),
)
