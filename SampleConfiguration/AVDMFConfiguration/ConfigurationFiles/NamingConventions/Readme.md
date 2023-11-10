# Naming Conventions
The AVDMF comes with a powerful and flexible name generation engine. It allows you to name the Azure resources according to your own organization's naming policy.
However, there are some assumptions for the naming of a few resource types that are hard coded.

## Naming Styles
The `NamingStyles` file must include a 'Default' naming style that is applied to all resource types. If a resource type does not have a naming style defined, the 'Default' is used.

A naming style is made up of components and (optional) separators. You can also set maximum allowed length and lower case for the name. See the example below
```JSON
{
    "ResourceType": "Default",
    "NameComponents": [
        "ResourceTypeAbv",
        "-",
        "HostPoolTypeAbv",
        "-",
        "DeploymentStageAbv",
        "-",
        "InstanceNumber"
    ],
    "MaxLength": 256,
    "LowerCase": false
}
```
## Components
The components of a name style can either be predefined abbreviation, like the `SubscriptionAbv` and `DeploymentStageAbv`

Some resource types must use a separate
